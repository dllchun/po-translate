import os
import polib
from openai import OpenAI
from dotenv import load_dotenv
import time
from collections import defaultdict

# Load environment variables
load_dotenv()

# Initialize OpenAI client
client = OpenAI(
    api_key=os.getenv('DEEPSEEK_API_KEY'),
    base_url="https://api.deepseek.com/v1"
)

# Translation cache to avoid re-translating identical strings
translation_cache = {}

def create_translation_prompt(texts):
    """Create a prompt for batch translation."""
    return f"""Please translate the following English texts to Traditional Chinese. 
Keep all HTML tags, variables (like @count, !status), and formatting intact.
Maintain a natural and professional tone suitable for a website UI.
Translate each line and keep the same order:

{texts}"""

def translate_batch(texts, max_retries=3):
    """Translate a batch of texts."""
    if not texts:
        return []
    
    # Create numbered list for clear separation
    numbered_texts = "\n".join(f"{i+1}. {text}" for i, text in enumerate(texts))
    
    for attempt in range(max_retries):
        try:
            response = client.chat.completions.create(
                model="deepseek-chat",
                messages=[
                    {"role": "system", "content": "You are a professional translator specializing in Traditional Chinese translations for website UI. Maintain accuracy and natural language flow."},
                    {"role": "user", "content": create_translation_prompt(numbered_texts)}
                ],
                temperature=0.3
            )
            translations = response.choices[0].message.content.strip().split("\n")
            # Clean up the numbered list format and any extra spaces
            translations = [t.split(". ", 1)[1] if ". " in t else t for t in translations]
            return translations
        except Exception as e:
            if attempt == max_retries - 1:
                print(f"Failed to translate batch after {max_retries} attempts: {e}")
                return ["" for _ in texts]
            time.sleep(2 ** attempt)  # Exponential backoff
    
    return ["" for _ in texts]

def process_po_file(input_file, output_file, batch_size=5, limit=100):
    """Process a PO file with batching and caching."""
    print(f"Processing {input_file}...")
    
    # Read input file
    po = polib.pofile(input_file)
    total_entries = len(po)
    processed = 0
    
    # Collect unique messages and their positions
    unique_messages = {}
    message_positions = defaultdict(list)
    
    # Only process the first 'limit' entries
    for i, entry in enumerate(po):
        if i >= limit:
            break
        if entry.msgid and not entry.msgstr:  # Only translate empty translations
            unique_messages[entry.msgid] = ""
            message_positions[entry.msgid].append(i)
    
    print(f"Found {len(unique_messages)} unique messages in first {limit} entries")
    
    # Process unique messages in batches
    unique_list = list(unique_messages.keys())
    batch_count = (len(unique_list) + batch_size - 1) // batch_size
    
    for batch_num in range(batch_count):
        start_idx = batch_num * batch_size
        end_idx = min((batch_num + 1) * batch_size, len(unique_list))
        batch = unique_list[start_idx:end_idx]
        
        # Skip cached translations
        to_translate = [msg for msg in batch if msg not in translation_cache]
        
        if to_translate:
            print(f"Translating batch {batch_num + 1}/{batch_count}...")
            print("Current batch:", to_translate)  # Print current batch for monitoring
            translations = translate_batch(to_translate)
            print("Translations received:", translations)  # Print translations for verification
            
            # Update cache with new translations
            for msg, trans in zip(to_translate, translations):
                translation_cache[msg] = trans
        
        # Update PO entries using cache
        for msg in batch:
            translation = translation_cache[msg]
            for pos in message_positions[msg]:
                po[pos].msgstr = translation
        
        processed += len(batch)
        print(f"Progress: {processed}/{len(unique_list)} unique messages ({processed/len(unique_list)*100:.1f}%)")
        
        # Save progress after each batch
        po.save(output_file)
        time.sleep(2)  # Increased delay between batches for safety
    
    print(f"Completed translation of first {limit} entries in {input_file}")
    print(f"Translated {len(unique_messages)} unique messages")
    print(f"Output saved to {output_file}")

def main():
    """Main function to process all PO files in the source directory."""
    source_dir = "source"
    output_dir = "output"
    
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Process all .po and .pot files
    for filename in os.listdir(source_dir):
        if filename.endswith(('.po', '.pot')):
            input_file = os.path.join(source_dir, filename)
            output_file = os.path.join(output_dir, filename.rsplit('.', 1)[0] + '.po')
            # Process only first 100 entries with smaller batch size
            process_po_file(input_file, output_file, batch_size=5, limit=100)

if __name__ == "__main__":
    main() 