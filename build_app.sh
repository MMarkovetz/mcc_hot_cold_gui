#!/usr/bin/env bash
# =====================================================================
# Build MCC_Hot_Cold_GUI.app for macOS.
#
# Prereq: Python 3.10+ installed (python.org installer or Homebrew).
# Usage:  cd into this folder in Terminal, then:
#             chmod +x build_app.sh   # first time only
#             ./build_app.sh
# =====================================================================

set -euo pipefail
cd "$(dirname "$0")"

PYTHON=${PYTHON:-python3}

echo
echo "=== MCC_Hot_Cold_GUI macOS build ==="
echo "Working directory: $(pwd)"
echo "Python:            $($PYTHON --version) ($(command -v "$PYTHON"))"
echo

# ---- [1/4] Venv -----------------------------------------------------
if [[ ! -x ".venv/bin/python" ]]; then
    echo "[1/4] Creating virtual environment (.venv)..."
    "$PYTHON" -m venv .venv
else
    echo "[1/4] .venv already present, reusing it."
fi

# shellcheck disable=SC1091
source .venv/bin/activate

# ---- [2/4] Dependencies ---------------------------------------------
echo
echo "[2/4] Installing/upgrading dependencies..."
python -m pip install --upgrade pip
python -m pip install -r requirements.txt pyinstaller

# ---- [3/4] Build -----------------------------------------------------
echo
echo "[3/4] Running PyInstaller (this takes ~3-8 minutes)..."
pyinstaller --clean --noconfirm MCC_Hot_Cold_GUI_mac.spec

APP_PATH="$(pwd)/dist/MCC_Hot_Cold_GUI.app"

# ---- [4/4] Report ----------------------------------------------------
echo
echo "[4/4] Done."
echo
echo "============================================================"
echo " App bundle: $APP_PATH"
echo "============================================================"
echo
echo "Test it by:  open '$APP_PATH'"
echo
echo "To share:    zip the .app for transport."
echo "             ditto -c -k --sequesterRsrc --keepParent \\"
echo "                  '$APP_PATH' MCC_Hot_Cold_GUI.app.zip"
echo
echo "Recipients:  on first launch macOS will say 'cannot verify the"
echo "             developer'.  Have them right-click (or Ctrl-click)"
echo "             the .app -> Open -> Open in the security dialog."
echo "             This only happens once per recipient."
echo
