@echo off
setlocal enabledelayedexpansion

:: Colors for Windows console
set "GREEN=[32m"
set "YELLOW=[33m"
set "RED=[31m"
set "NC=[0m"

:: Function to perform cleanup
:cleanup
echo %YELLOW%Performing cleanup...%NC%
:: Deactivate virtual environment if active
if defined VIRTUAL_ENV (
    echo Deactivating virtual environment...
    call deactivate 2>nul
)
:: Remove virtual environment
if exist venv (
    echo Removing virtual environment...
    rmdir /s /q venv 2>nul
)
:: Remove Python cache files
if exist __pycache__ (
    echo Removing Python cache files...
    rmdir /s /q __pycache__ 2>nul
)
:: Remove .pyc files
echo Removing temporary Python files...
del /s /q *.pyc 2>nul
echo %GREEN%Cleanup completed.%NC%
echo.
goto :eof

:: Error handling function
:handle_error
echo %RED%Error: %~1%NC%
call :cleanup
echo Press any key to exit...
pause >nul
exit /b 1

:: Main script starts here
echo ======================================
echo %GREEN%PO File Translation Setup Script%NC%
echo ======================================
echo.

:: Initial cleanup
call :cleanup

:: Check if Python is installed
python --version > nul 2>&1
if errorlevel 1 (
    echo %RED%Error: Python is not installed. Please install Python first.%NC%
    echo Visit: https://www.python.org/downloads/
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

:: Create virtual environment with error handling
echo %GREEN%Creating virtual environment...%NC%
python -m venv venv || call :handle_error "Failed to create virtual environment. Please check Python installation."

:: Check if venv creation was successful
if not exist venv (
    call :handle_error "Failed to create virtual environment directory."
)

:: Activate virtual environment and install packages with error handling
echo %GREEN%Activating virtual environment and installing packages...%NC%
call venv\Scripts\activate.bat || call :handle_error "Failed to activate virtual environment."

:: Upgrade pip with error handling
python -m pip install --upgrade pip || call :handle_error "Failed to upgrade pip."

:: Install requirements with error handling
pip install -r requirements.txt || call :handle_error "Failed to install requirements."

:: Create .env file if it doesn't exist
if not exist .env (
    echo %GREEN%Creating .env file...%NC%
    echo DEEPSEEK_API_KEY='your_api_key_here'> .env
    echo %YELLOW%Warning: Please update the DEEPSEEK_API_KEY in .env file with your actual API key%NC%
)

:: Create directories with error handling
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
    call venv\Scripts\activate.bat
    python translate_po.py
    if errorlevel 1 (
        echo %RED%Translation failed.%NC%
    ) else (
        echo %GREEN%Translation completed successfully.%NC%
    )
    call :cleanup
    echo.
    echo Press any key to return to menu...
    pause >nul
    goto MENU
)
if "%choice%"=="4" (
    echo.
    echo %GREEN%Cleaning up and exiting...%NC%
    call :cleanup
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