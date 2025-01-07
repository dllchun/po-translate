# PO File Translator

This tool translates PO (Portable Object) files from English to Traditional Chinese using the DeepSeek API. It's designed to handle website UI text translations with proper formatting and context awareness.

## Features

- Batch translation processing for better efficiency
- Maintains HTML tags and variables in translations
- Organizes files in source and output directories
- Professional UI/UX-focused translations
- Progress tracking during translation
- Error handling and recovery
- Automatic detection and processing of all PO files
- Skips already translated entries
- Preserves original file names with '_zh' suffix
- Cross-platform support (Windows, macOS, Linux)
- Easy cleanup and maintenance

## Prerequisites

- Python 3.6 or higher
- DeepSeek API key (obtain from [DeepSeek Platform](https://platform.deepseek.com))

## Directory Structure

```
.
├── source/           # Place your source PO files here
│   ├── file1.po     # Any PO file will be processed
│   └── file2.po     # No specific naming required
├── output/          # Translated files will be saved here
│   ├── file1_zh.po  # Original name + _zh suffix
│   └── file2_zh.po
├── translate_po.py  # Main translation script
├── setup.sh        # Setup script for macOS/Linux
├── setup.bat       # Setup script for Windows
├── cleanup.bat     # Cleanup script for Windows
├── requirements.txt # Python dependencies
└── .env            # Environment file for API key
```

## Quick Start (Windows)

1. Make sure you have Python 3 installed:
```cmd
python --version
```
If not installed, download from [python.org](https://www.python.org/downloads/)

2. Run the setup script by double-clicking `setup.bat` or running:
```cmd
setup.bat
```

3. Choose from the interactive menu:
   - Open source directory to add PO files
   - Edit API key in .env file
   - Start translation
   - Clean up temporary files
   - Exit

4. The script will guide you through the process and handle virtual environment activation automatically.

## Cleanup Options

### Using the Interactive Menu
1. Run `setup.bat`
2. Choose option 4 (Clean up)
3. The script will remove:
   - Virtual environment (venv)
   - Python cache files
   - Temporary files

### Using the Cleanup Script
1. Run `cleanup.bat`
2. Confirm when prompted
3. The script will clean up all temporary files
4. Run `setup.bat` again when you need to use the translator

## Quick Start (macOS/Linux)

1. Make sure you have Python 3 installed:
```bash
python3 --version
```

2. Run the setup script:
```bash
chmod +x setup.sh  # Make the script executable
./setup.sh
```

3. Update the API key in `.env` file:
```bash
DEEPSEEK_API_KEY='your_api_key_here'
```

4. Place your PO files in the `source` directory:
   - You can put any number of PO files
   - Files can have any name with `.po` extension
   - Original file structure will be preserved

5. Activate the virtual environment:
```bash
source venv/bin/activate
```

6. Run the translation script:
```bash
python translate_po.py
```

## Configuration

- `BATCH_SIZE`: Number of texts to translate in one API call (default: 5)
- Translation settings can be adjusted in `translate_po.py`
- The script includes a delay between batches to respect API rate limits

## Notes

- The virtual environment needs to be activated each time you open a new terminal/command prompt
- Translated files will be saved in the `output` directory with a `_zh` suffix
- The script will skip any entries that already have translations
- HTML tags and variables (like `<strong>`, `@count`) will be preserved
- Error messages and progress will be displayed during translation
- The script automatically processes all PO files in the source directory
- Progress tracking shows number of entries and untranslated strings per file

## Troubleshooting

1. If Python is not found:
   - Windows: Download and install from [python.org](https://www.python.org/downloads/)
   - Make sure to check "Add Python to PATH" during installation
   - macOS/Linux: Install using package manager (brew, apt, etc.)

2. If the virtual environment fails to create:
   - Windows: Run Command Prompt as Administrator
   - Try removing the `venv` directory and running setup again
   - Ensure you have write permissions in the directory

3. If translations fail:
   - Check your API key in the `.env` file
   - Ensure you have internet connectivity
   - Check the DeepSeek API status

4. If no files are processed:
   - Verify that your PO files are in the `source` directory
   - Check that the files have `.po` extension
   - Ensure you have read permissions for the files

5. Windows-specific issues:
   - If you get "Permission denied": Run Command Prompt as Administrator
   - If activation fails: Use `venv\Scripts\activate.bat`
   - If colors don't show: Use Windows Terminal or newer Command Prompt

## Support

For issues or questions:
1. Check the error messages in the console
2. Verify your API key and internet connection
3. Contact DeepSeek support for API-related issues 