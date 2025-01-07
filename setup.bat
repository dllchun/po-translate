@echo off
setlocal enabledelayedexpansion

:: Colors for Windows console
set "GREEN=[32m"
set "YELLOW=[33m"
set "RED=[31m"
set "NC=[0m"

echo ======================================
echo %GREEN%PO File Translation Setup Script%NC%
echo ======================================
echo.

:: Check if Python is installed
python --version > nul 2>&1
if errorlevel 1 (
    echo %RED%Error: Python is not installed. Please install Python first.%NC%
    echo Visit: https://www.python.org/downloads/
    pause
    exit /b 1
)

:: Check if virtual environment exists and remove if it does
if exist venv (
    echo %YELLOW%Warning: Existing virtual environment found. Removing...%NC%
    rmdir /s /q venv
)

:: Create virtual environment
echo %GREEN%Creating virtual environment...%NC%
python -m venv venv

:: Check if venv creation was successful
if not exist venv (
    echo %RED%Error: Failed to create virtual environment.%NC%
    pause
    exit /b 1
)

:: Activate virtual environment and install packages
echo %GREEN%Activating virtual environment and installing packages...%NC%
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt

:: Create .env file if it doesn't exist
if not exist .env (
    echo %GREEN%Creating .env file...%NC%
    echo DEEPSEEK_API_KEY='your_api_key_here'> .env
    echo %YELLOW%Warning: Please update the DEEPSEEK_API_KEY in .env file with your actual API key%NC%
)

:: Create directories
echo %GREEN%Creating required directories...%NC%
if not exist source mkdir source
if not exist output mkdir output

:: Move any PO files to source directory if they exist in current directory
if exist *.po (
    echo %GREEN%Moving PO files to source directory...%NC%
    move *.po source\ > nul 2>&1
)

echo.
echo ======================================
echo %GREEN%Setup completed successfully!%NC%
echo ======================================
echo.
echo To start using the translation tool:
echo.
echo %GREEN%1. Make sure your source PO files are in the 'source' directory%NC%
echo %GREEN%2. Update the DEEPSEEK_API_KEY in the .env file%NC%
echo %GREEN%3. Activate the virtual environment:%NC%
echo    venv\Scripts\activate.bat
echo %GREEN%4. Run the translation script:%NC%
echo    python translate_po.py
echo.
echo %GREEN%Translated files will be saved in the 'output' directory%NC%
echo.
echo %YELLOW%Note: You need to activate the virtual environment each time you open a new command prompt%NC%
echo ======================================

pause 