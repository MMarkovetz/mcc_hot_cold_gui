# -*- mode: python ; coding: utf-8 -*-
#
# PyInstaller spec for a single-file Windows .exe build of MCC_Hot_Cold_GUI.
#
# Build:
#     pip install -r requirements.txt pyinstaller
#     pyinstaller MCC_Hot_Cold_GUI.spec
#
# The resulting exe will be written to dist\MCC_Hot_Cold_GUI.exe

from PyInstaller.utils.hooks import collect_submodules

block_cipher = None

hiddenimports = []
# Matplotlib + Qt backend needs its submodules collected explicitly sometimes.
hiddenimports += collect_submodules('matplotlib.backends')

a = Analysis(
    ['MCC_Hot_Cold_GUI.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    # Exclude backends we don't use to slim the exe.
    excludes=['tkinter', 'PyQt5', 'PyQt6'],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name='MCC_Hot_Cold_GUI',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,          # no console window (GUI app)
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
