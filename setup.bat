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

:: Register cleanup on script exit
set "script_dir=%~dp0"
set "cleanup_cmd=call :cleanup"
for /F "tokens=2 delims==" %%a in ('set') do if /I not "%%a"=="%cleanup_cmd%" set "%%a="

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
    pause
    exit /b 1
)

:: Create virtual environment with error handling
echo %GREEN%Creating virtual environment...%NC%
python -m venv venv
if errorlevel 1 (
    echo %RED%Error: Failed to create virtual environment. Please check Python installation.%NC%
    pause
    exit /b 1
)

:: Check if venv creation was successful
if not exist venv (
    echo %RED%Error: Failed to create virtual environment directory.%NC%
    pause
    exit /b 1
)

:: Activate virtual environment and install packages with error handling
echo %GREEN%Activating virtual environment and installing packages...%NC%
call venv\Scripts\activate.bat
if errorlevel 1 (
    echo %RED%Error: Failed to activate virtual environment.%NC%
    pause
    exit /b 1
)

:: Upgrade pip with error handling
python -m pip install --upgrade pip
if errorlevel 1 (
    echo %RED%Error: Failed to upgrade pip.%NC%
    pause
    exit /b 1
)

:: Install requirements with error handling
pip install -r requirements.txt
if errorlevel 1 (
    echo %RED%Error: Failed to install requirements.%NC%
    pause
    exit /b 1
)

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
echo %YELLOW%Note: Virtual environment will be cleaned up when you exit%NC%
echo ======================================
echo.

:PROMPT
echo What would you like to do next?
echo.
echo %GREEN%[1]%NC% Open source directory to add PO files
echo %GREEN%[2]%NC% Edit .env file to set API key
echo %GREEN%[3]%NC% Start translation (will activate venv)
echo %GREEN%[4]%NC% Exit
echo.
set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    start explorer "source"
    goto PROMPT
)
if "%choice%"=="2" (
    notepad .env
    goto PROMPT
)
if "%choice%"=="3" (
    call venv\Scripts\activate.bat
    python translate_po.py
    call :cleanup
    pause
    exit /b 0
)
if "%choice%"=="4" (
    echo.
    echo %GREEN%Cleaning up and exiting...%NC%
    call :cleanup
    pause
    exit /b 0
)

echo.
echo %RED%Invalid choice. Please try again.%NC%
echo.
goto PROMPT 