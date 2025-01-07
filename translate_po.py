import os
import polib
import time
import glob
from openai import OpenAI
from dotenv import load_dotenv
from typing import List, Dict
import json

# Load environment variables from .env file
load_dotenv()

DEEPSEEK_API_KEY = os.getenv('DEEPSEEK_API_KEY')
client = OpenAI(api_key=DEEPSEEK_API_KEY, base_url="https://api.deepseek.com")

BATCH_SIZE = 5  # Number of texts to translate in one API call
SOURCE_DIR = "source"
OUTPUT_DIR = "output"

def create_translation_prompt(texts: List[str]) -> str:
    """Create a prompt for batch translation."""
    formatted_texts = "\n".join([f"{i+1}. {text}" for i, text in enumerate(texts)])
    return f"""Please translate the following website UI texts to Traditional Chinese (繁體中文). 
These are UI elements that users will see on a website, so make them clear, natural, and easy to understand.

Rules:
1. Keep HTML tags and variables unchanged (like <strong>, @count, etc.)
2. Maintain a consistent and professional tone
3. Use common Traditional Chinese terms for better user understanding
4. Return translations in numbered list format, matching the input format
5. Only return the translations, no explanations

Input texts:
{formatted_texts}"""

def parse_numbered_list(text: str, expected_count: int) -> List[str]:
    """Parse numbered list response into a list of translations."""
    lines = [line.strip() for line in text.split('\n') if line.strip()]
    translations = []
    current_translation = []
    
    for line in lines:
        if line[0].isdigit() and '.' in line:
            if current_translation:
                translations.append(' '.join(current_translation))
                current_translation = []
            current_translation.append(line.split('.', 1)[1].strip())
        else:
            current_translation.append(line.strip())
    
    if current_translation:
        translations.append(' '.join(current_translation))
    
    # Ensure we have the expected number of translations
    if len(translations) != expected_count:
        print(f"Warning: Expected {expected_count} translations but got {len(translations)}")
        # Pad with empty strings if necessary
        translations.extend([''] * (expected_count - len(translations)))
    
    return translations[:expected_count]

def translate_batch(texts: List[str]) -> List[str]:
    """Translate a batch of texts using DeepSeek API."""
    try:
        response = client.chat.completions.create(
            model="deepseek-chat",
            messages=[
                {"role": "system", "content": "You are a professional UI/UX translator specializing in Traditional Chinese localization."},
                {"role": "user", "content": create_translation_prompt(texts)}
            ],
            temperature=0.2  # Lower temperature for more consistent translations
        )
        
        translation_text = response.choices[0].message.content.strip()
        return parse_numbered_list(translation_text, len(texts))
    except Exception as e:
        print(f"Error translating batch: {e}")
        return [""] * len(texts)

def translate_po_file(input_file: str, output_file: str):
    """Translate a PO file and save the translations."""
    if not os.path.exists(input_file):
        print(f"Input file {input_file} not found")
        return
    
    # Load the PO file
    po = polib.pofile(input_file)
    total_entries = len(po)
    untranslated_entries = len([e for e in po if not e.msgstr])
    
    print(f"Found {total_entries} entries ({untranslated_entries} untranslated) in {input_file}")
    
    if untranslated_entries == 0:
        print("All entries are already translated. Skipping file.")
        return
    
    # Prepare batches
    current_batch = []
    current_entries = []
    
    for entry in po:
        if entry.msgid and not entry.msgstr:  # Only translate if msgstr is empty
            current_batch.append(entry.msgid)
            current_entries.append(entry)
            
            if len(current_batch) >= BATCH_SIZE:
                print(f"Translating batch of {len(current_batch)} entries...")
                translations = translate_batch(current_batch)
                
                # Update entries with translations
                for entry, translation in zip(current_entries, translations):
                    if translation:
                        entry.msgstr = translation
                
                current_batch = []
                current_entries = []
                time.sleep(0.5)  # Small delay between batches
    
    # Translate remaining entries
    if current_batch:
        print(f"Translating final batch of {len(current_batch)} entries...")
        translations = translate_batch(current_batch)
        for entry, translation in zip(current_entries, translations):
            if translation:
                entry.msgstr = translation
    
    # Save the translated file
    po.save(output_file)
    print(f"Translations saved to {output_file}")

def get_po_files() -> List[str]:
    """Get all PO files from the source directory."""
    return glob.glob(os.path.join(SOURCE_DIR, "*.po"))

def main():
    """Main function to process PO files."""
    if not DEEPSEEK_API_KEY:
        print("Please set the DEEPSEEK_API_KEY in your .env file")
        return
    
    # Ensure directories exist
    os.makedirs(SOURCE_DIR, exist_ok=True)
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Get all PO files from source directory
    source_files = get_po_files()
    
    if not source_files:
        print(f"No PO files found in {SOURCE_DIR} directory")
        return
    
    print(f"Found {len(source_files)} PO files to process")
    
    # Process each PO file
    for source_file in source_files:
        filename = os.path.basename(source_file)
        base_name, _ = os.path.splitext(filename)
        output_file = os.path.join(OUTPUT_DIR, f"{base_name}_zh.po")
        
        print(f"\nProcessing {filename}...")
        translate_po_file(source_file, output_file)
    
    print("\nAll files processed successfully!")

if __name__ == "__main__":
    main() 