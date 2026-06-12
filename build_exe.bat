@echo off
REM =====================================================================
REM Build MCC_Hot_Cold_GUI.exe as a single-file Windows executable.
REM
REM Prereq: Python 3.10+ on PATH. Run this .bat from its own folder.
REM =====================================================================

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo [1/4] Creating virtual environment (.venv) if needed...
if not exist ".venv\Scripts\python.exe" (
    python -m venv .venv || goto :error
)

echo [2/4] Installing/upgrading dependencies...
call ".venv\Scripts\activate.bat" || goto :error
python -m pip install --upgrade pip || goto :error
python -m pip install -r requirements.txt pyinstaller || goto :error

echo [3/4] Running PyInstaller...
pyinstaller --clean MCC_Hot_Cold_GUI.spec || goto :error

echo [4/4] Done.
echo Your executable is at:  %cd%\dist\MCC_Hot_Cold_GUI.exe
goto :eof

:error
echo.
echo BUILD FAILED.
exit /b 1
