@echo off
REM =====================================================================
REM Build MCC_Hot_Cold_GUI.exe as a single-file Windows executable.
REM
REM Prereq: Python 3.10+ installed from python.org (NOT the Microsoft Store
REM         alias).  The "py" launcher must be available.
REM Usage:  double-click this file, or run it from cmd.exe in this folder.
REM =====================================================================

setlocal enabledelayedexpansion
cd /d "%~dp0"

echo.
echo === MCC_Hot_Cold_GUI build ===
echo Working directory: %CD%

REM ---- Verify we have a real Python (not the Microsoft Store stub) ----
where py >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: The 'py' launcher was not found.
    echo Install Python from https://www.python.org/downloads/ - be sure to
    echo tick 'Add python.exe to PATH' AND 'py launcher' in the installer.
    goto :error
)

py --version

echo.
echo [1/4] Creating virtual environment (.venv) if needed...
if not exist ".venv\Scripts\python.exe" (
    py -m venv .venv || goto :error
) else (
    echo      .venv already present, reusing it.
)

echo.
echo [2/4] Installing/upgrading dependencies...
call ".venv\Scripts\activate.bat" || goto :error
python -m pip install --upgrade pip || goto :error
python -m pip install -r requirements.txt pyinstaller || goto :error

echo.
echo [3/4] Running PyInstaller (this takes ~3-8 minutes)...
pyinstaller --clean --noconfirm MCC_Hot_Cold_GUI.spec || goto :error

echo.
echo [4/4] Done.
echo.
echo ============================================================
echo  Executable: %CD%\dist\MCC_Hot_Cold_GUI.exe
echo ============================================================
echo.
echo Test it by double-clicking dist\MCC_Hot_Cold_GUI.exe.
echo To share it, zip the single .exe file - no other files needed.
echo.
echo If a recipient sees 'DLL load failed' on first launch, install
echo the Visual C++ 2015-2022 redistributable from:
echo   https://aka.ms/vs/17/release/vc_redist.x64.exe
echo.
goto :eof

:error
echo.
echo ============================================================
echo  BUILD FAILED.  See the messages above for the cause.
echo ============================================================
exit /b 1
