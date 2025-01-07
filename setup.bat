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
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Create virtual environment
echo %GREEN%Creating virtual environment...%NC%
python -m venv venv
if errorlevel 1 (
    echo %RED%Error: Failed to create virtual environment. Please check Python installation.%NC%
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Check if venv creation was successful
if not exist venv (
    echo %RED%Error: Failed to create virtual environment directory.%NC%
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Activate virtual environment and install packages
echo %GREEN%Activating virtual environment and installing packages...%NC%
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo %RED%Error: Failed to activate virtual environment.%NC%
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Upgrade pip
python -m pip install --upgrade pip
if errorlevel 1 (
    echo %RED%Error: Failed to upgrade pip.%NC%
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Install requirements
pip install -r requirements.txt
if errorlevel 1 (
    echo %RED%Error: Failed to install requirements.%NC%
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Create .env file if it doesn't exist
if not exist .env (
    echo %GREEN%Creating .env file...%NC%
    echo DEEPSEEK_API_KEY='your_api_key_here'> .env
    echo %YELLOW%Warning: Please update the DEEPSEEK_API_KEY in .env file with your actual API key%NC%
)

:: Create directories
echo %GREEN%Creating required directories...%NC%
mkdir source 2>nul
mkdir output 2>nul

:: Move any PO files to source directory if they exist
if exist *.po (
    echo %GREEN%Moving PO files to source directory...%NC%
    move *.po source\ 2>nul
)

echo.
echo ======================================
echo %GREEN%Setup completed successfully!%NC%
echo ======================================
echo.

:MENU
echo What would you like to do?
echo.
echo %GREEN%[1]%NC% Open source directory to add PO files
echo %GREEN%[2]%NC% Edit .env file to set API key
echo %GREEN%[3]%NC% Start translation
echo %GREEN%[4]%NC% Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    start explorer "source"
    echo.
    goto MENU
)
if "%choice%"=="2" (
    start notepad .env
    echo.
    goto MENU
)
if "%choice%"=="3" (
    echo %GREEN%Starting translation...%NC%
    python translate_po.py
    if errorlevel 1 (
        echo %RED%Translation failed.%NC%
    ) else (
        echo %GREEN%Translation completed successfully.%NC%
    )
    echo.
    echo Press any key to return to menu...
    pause >nul
    goto MENU
)
if "%choice%"=="4" (
    echo.
    echo %GREEN%Exiting...%NC%
    echo Press any key to exit...
    pause >nul
    exit /b 0
)

echo.
echo %RED%Invalid choice. Please try again.%NC%
echo.
goto MENU

:: Final pause to prevent window from closing
pause >nul 