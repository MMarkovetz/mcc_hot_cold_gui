# =====================================================================
# Build MCC_Hot_Cold_GUI.exe as a single-file Windows executable.
#
# Prereq: Python 3.10+ from python.org (the Microsoft Store stub does
#         not work).  The 'py' launcher must be on PATH.
# Usage:  cd into this folder in PowerShell, then run:
#             .\build_exe.ps1
#         If you see an execution-policy error, run once:
#             Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
# =====================================================================

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

function Die($msg) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " BUILD FAILED: $msg" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== MCC_Hot_Cold_GUI build ===" -ForegroundColor Cyan
Write-Host "Working directory: $PSScriptRoot"

# ---- Verify Python ----
if (-not (Get-Command py -ErrorAction SilentlyContinue)) {
    Die "The 'py' launcher was not found. Install Python from https://www.python.org/downloads/ and tick 'Add Python to PATH' and 'py launcher' in the installer."
}
py --version

# ---- [1/4] Create venv ----
Write-Host ""
Write-Host "[1/4] Creating virtual environment (.venv) if needed..."
if (-not (Test-Path ".venv\Scripts\python.exe")) {
    py -m venv .venv
    if ($LASTEXITCODE -ne 0) { Die "py -m venv .venv failed." }
} else {
    Write-Host "      .venv already present, reusing it."
}

# ---- [2/4] Install deps ----
Write-Host ""
Write-Host "[2/4] Installing/upgrading dependencies..."
. .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) { Die "pip upgrade failed." }
python -m pip install -r requirements.txt pyinstaller
if ($LASTEXITCODE -ne 0) { Die "pip install failed." }

# ---- [3/4] Build ----
Write-Host ""
Write-Host "[3/4] Running PyInstaller (this takes ~3-8 minutes)..."
pyinstaller --clean --noconfirm MCC_Hot_Cold_GUI.spec
if ($LASTEXITCODE -ne 0) { Die "PyInstaller returned a non-zero exit code." }

# ---- [4/4] Report ----
$exePath = Join-Path $PSScriptRoot "dist\MCC_Hot_Cold_GUI.exe"
Write-Host ""
Write-Host "[4/4] Done." -ForegroundColor Green
Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host " Executable: $exePath" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Test it by double-clicking the .exe."
Write-Host "To share it, zip the single .exe file - no other files needed."
Write-Host ""
Write-Host "If a recipient sees 'DLL load failed' on first launch, install"
Write-Host "the Visual C++ 2015-2022 redistributable from:"
Write-Host "  https://aka.ms/vs/17/release/vc_redist.x64.exe"
Write-Host ""
