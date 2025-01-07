@echo off
setlocal enabledelayedexpansion

:: Colors for Windows console
set "GREEN=[32m"
set "YELLOW=[33m"
set "RED=[31m"
set "NC=[0m"

echo ======================================
echo %YELLOW%PO File Translation Cleanup Script%NC%
echo ======================================
echo.

echo %YELLOW%This will remove:
echo - Virtual environment (venv)
echo - Python cache files
echo - Temporary files%NC%
echo.
set /p confirm="Are you sure you want to proceed? (Y/N): "

if /i not "%confirm%"=="Y" (
    echo.
    echo %GREEN%Cleanup cancelled.%NC%
    pause
    exit /b 0
)

echo.
echo %YELLOW%Cleaning up...%NC%

:: Deactivate virtual environment if active
if defined VIRTUAL_ENV (
    echo Deactivating virtual environment...
    call deactivate
)

:: Remove virtual environment
if exist venv (
    echo Removing virtual environment...
    rmdir /s /q venv
)

:: Remove Python cache files
if exist __pycache__ (
    echo Removing Python cache files...
    rmdir /s /q __pycache__
)

:: Remove .pyc files
echo Removing temporary Python files...
del /s /q *.pyc 2>nul

echo.
echo %GREEN%Cleanup completed successfully!%NC%
echo %YELLOW%Run setup.bat to reinstall the environment when needed.%NC%
echo ======================================
pause 