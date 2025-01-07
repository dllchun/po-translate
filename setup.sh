#!/bin/bash

# Text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}==>${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

# Print welcome message
echo "======================================"
print_message "PO File Translation Setup Script"
echo "======================================"
echo ""

# Check if virtual environment exists and remove if it does
if [ -d "venv" ]; then
    print_warning "Existing virtual environment found. Removing..."
    rm -rf venv
fi

# Create virtual environment
print_message "Creating virtual environment..."
python3 -m venv venv

# Check if venv creation was successful
if [ ! -d "venv" ]; then
    print_error "Failed to create virtual environment."
    exit 1
fi

# Activate virtual environment
print_message "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_message "Upgrading pip..."
python -m pip install --upgrade pip

# Install requirements
print_message "Installing required packages..."
pip install -r requirements.txt

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_message "Creating .env file..."
    echo "DEEPSEEK_API_KEY='your_api_key_here'" > .env
    print_warning "Please update the DEEPSEEK_API_KEY in .env file with your actual API key"
fi

# Create source and output directories if they don't exist
print_message "Creating required directories..."
mkdir -p source output

# Check if source files exist in the current directory and move them if they do
if [ -f "drupalt_set0051.po" ] || [ -f "drupalt_set0052.po" ]; then
    print_message "Moving source files to source directory..."
    mv drupalt_set*.po source/ 2>/dev/null || true
fi

echo ""
echo "======================================"
print_message "Setup completed successfully!"
echo "======================================"
echo ""
echo "To start using the translation tool:"
echo ""
print_message "1. Make sure your source PO files are in the 'source' directory"
print_message "2. Update the DEEPSEEK_API_KEY in the .env file"
print_message "3. Activate the virtual environment:"
echo "   source venv/bin/activate"
print_message "4. Run the translation script:"
echo "   python translate_po.py"
echo ""
print_message "Translated files will be saved in the 'output' directory"
echo ""
print_warning "Note: You need to activate the virtual environment each time you open a new terminal"
echo "======================================" 