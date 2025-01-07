#!/bin/bash

# Colors for terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
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

# Error handling function
handle_error() {
    print_error "$1"
    exit 1
}

echo "======================================"
print_message "PO File Translation Setup Script"
echo "======================================"
echo

# Automatic cleanup at start
print_warning "Performing automatic cleanup..."

# Deactivate virtual environment if active
if [[ -n "${VIRTUAL_ENV}" ]]; then
    echo "Deactivating virtual environment..."
    deactivate 2>/dev/null || true
fi

# Remove existing virtual environment
if [ -d "venv" ]; then
    echo "Removing existing virtual environment..."
    rm -rf venv
fi

# Remove Python cache files
if [ -d "__pycache__" ]; then
    echo "Removing Python cache files..."
    rm -rf __pycache__
fi

# Remove .pyc files
echo "Removing temporary Python files..."
find . -type f -name "*.pyc" -delete 2>/dev/null

print_message "Cleanup completed."
echo

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    handle_error "Python 3 is not installed. Please install Python 3 first."
fi

# Create virtual environment with error handling
print_message "Creating virtual environment..."
python3 -m venv venv || handle_error "Failed to create virtual environment. Please check Python installation."

# Check if venv creation was successful
if [ ! -d "venv" ]; then
    handle_error "Failed to create virtual environment directory."
fi

# Activate virtual environment
print_message "Activating virtual environment..."
source venv/bin/activate || handle_error "Failed to activate virtual environment."

# Upgrade pip with error handling
print_message "Upgrading pip..."
python -m pip install --upgrade pip || handle_error "Failed to upgrade pip."

# Install requirements with error handling
print_message "Installing required packages..."
pip install -r requirements.txt || handle_error "Failed to install requirements."

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_message "Creating .env file..."
    echo "DEEPSEEK_API_KEY='your_api_key_here'" > .env
    print_warning "Please update the DEEPSEEK_API_KEY in .env file with your actual API key"
fi

# Create directories
print_message "Creating required directories..."
mkdir -p source output

# Move any PO files to source directory if they exist
if ls *.po 1> /dev/null 2>&1; then
    print_message "Moving PO files to source directory..."
    mv *.po source/ 2>/dev/null || true
fi

echo
echo "======================================"
print_message "Setup completed successfully!"
echo "======================================"
echo
echo "To start using the translation tool:"
echo
print_message "1. Make sure your source PO files are in the 'source' directory"
print_message "2. Update the DEEPSEEK_API_KEY in the .env file"
print_message "3. Activate the virtual environment:"
echo "   source venv/bin/activate"
print_message "4. Run the translation script:"
echo "   python translate_po.py"
echo
print_message "Translated files will be saved in the 'output' directory"
echo
print_warning "Note: You need to activate the virtual environment each time you open a new terminal"
echo "======================================"

# Make the script executable
chmod +x translate_po.py 2>/dev/null || true 