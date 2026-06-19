# -*- mode: python ; coding: utf-8 -*-
#
# PyInstaller spec for a macOS .app build of MCC_Hot_Cold_GUI.
#
# Build (must be run ON macOS - PyInstaller does NOT cross-compile):
#     python3 -m venv .venv
#     source .venv/bin/activate
#     pip install -r requirements.txt pyinstaller
#     pyinstaller --clean MCC_Hot_Cold_GUI_mac.spec
#
# Or run build_app.sh which automates the full pipeline.
#
# Output: dist/MCC_Hot_Cold_GUI.app  - drag to /Applications.
#         (also dist/MCC_Hot_Cold_GUI - the raw single-binary, ignored
#          unless you want a CLI-style distribution instead.)
#
# Architecture: the .app produced runs ONLY on the architecture of the
# build machine.  Build on Apple Silicon for arm64-only, on Intel for
# x86_64-only.  To ship a single .app that runs everywhere, set
# target_arch='universal2' below AND install universal Python + wheels.

from PyInstaller.utils.hooks import collect_submodules, collect_data_files

block_cipher = None

hiddenimports = []
hiddenimports += collect_submodules('matplotlib.backends')
hiddenimports += collect_submodules('scipy')
hiddenimports += [
    'scipy.io.matlab',
    'scipy.signal',
    'scipy.ndimage',
    'scipy.stats',
    'scipy.special',
    'scipy._lib.messagestream',
]
hiddenimports += [
    'openpyxl',
    'openpyxl.workbook',
    'openpyxl.styles',
    'openpyxl.utils',
    'PIL',
    'PIL.Image',
    'PIL.TiffImagePlugin',
]
hiddenimports += [
    'pydicom',
    'pydicom.encoders',
    'pydicom.encoders.native',
    'pydicom.pixel_data_handlers',
    'pydicom.pixel_data_handlers.numpy_handler',
    'pydicom.pixel_data_handlers.pillow_handler',
    'pydicom.pixel_data_handlers.gdcm_handler',
    'pydicom.pixel_data_handlers.pylibjpeg_handler',
]

datas = []
datas += collect_data_files('pydicom')
datas += collect_data_files('scipy')

a = Analysis(
    ['MCC_Hot_Cold_GUI.py'],
    pathex=[],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['tkinter', 'PyQt5', 'PyQt6', 'PySide2'],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

# The raw executable (a.k.a. the contents of the .app's MacOS/ folder).
exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='MCC_Hot_Cold_GUI',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    # Pick one of: None (default = native build arch), 'x86_64', 'arm64',
    # or 'universal2' (requires a universal Python).
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)

# Collect everything into a folder PyInstaller will then wrap as a .app.
coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=False,
    upx_exclude=[],
    name='MCC_Hot_Cold_GUI',
)

# The .app bundle.
app = BUNDLE(
    coll,
    name='MCC_Hot_Cold_GUI.app',
    icon=None,  # Replace with path to a .icns file if you want an icon.
    bundle_identifier='com.markovetz.mcc-hot-cold-gui',
    info_plist={
        'CFBundleShortVersionString': '1.0.0',
        'CFBundleVersion': '1.0.0',
        'NSHighResolutionCapable': 'True',
        'NSRequiresAquaSystemAppearance': 'False',
        'LSMinimumSystemVersion': '10.15',
    },
)
