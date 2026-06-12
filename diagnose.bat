@echo off
REM =====================================================================
REM Deep diagnostic for PySide6 "DLL load failed" / "procedure not found"
REM Run from python_port\ with the venv activated:
REM    .venv\Scripts\activate
REM    diagnose.bat
REM =====================================================================

setlocal
cd /d "%~dp0"

echo.
echo === Python ==========================================================
python --version
python -c "import sys, platform; print(sys.executable); print(platform.architecture())"

echo.
echo === Installed Qt packages (PySide6 + shiboken6 MUST match) =========
pip show PySide6 2>nul | findstr /R "^Name: ^Version:"
pip show PySide6-Essentials 2>nul | findstr /R "^Name: ^Version:"
pip show PySide6-Addons 2>nul | findstr /R "^Name: ^Version:"
pip show shiboken6 2>nul | findstr /R "^Name: ^Version:"

echo.
echo === Visual C++ Redistributable 2015-2022 (x64) =====================
REM The registry key is the one MS uses for the VS2015-2022 x64 redist.
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" 2>nul
if errorlevel 1 (
    echo   NOT FOUND - this is almost certainly your problem.
    echo   Install from: https://aka.ms/vs/17/release/vc_redist.x64.exe
) else (
    echo   Installed.
)

echo.
echo === Check vcruntime140_1.dll (the common missing file) =============
where vcruntime140.dll 2>nul
where vcruntime140_1.dll 2>nul
if errorlevel 1 (
    echo   vcruntime140_1.dll NOT on PATH - reinstall VC++ Redist x64.
)

echo.
echo === Try to import shiboken6 on its own ==============================
python -c "import shiboken6; print('shiboken6 OK, version', shiboken6.__version__)" 2>&1

echo.
echo === Verbose Qt plugin debug =========================================
set QT_DEBUG_PLUGINS=1
python -c "from PySide6 import QtCore; print('QtCore OK')" 2>&1

echo.
echo === PySide6 folder contents (should have Qt6Core.dll) =============
dir /b "%VIRTUAL_ENV%\Lib\site-packages\PySide6\Qt6*.dll" 2>nul | findstr /i "Qt6Core Qt6Gui Qt6Widgets"

echo.
echo Done. Copy the full window output when reporting.
endlocal
pause
