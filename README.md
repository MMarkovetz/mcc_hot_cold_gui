# MCC_Hot_Cold_GUI - Python port

Python/PySide6 port of the MATLAB App Designer application
`MCC_Hot_Cold_GUI.mlapp` ("Deposition and MCC Analyzer").

## Status

- **GUI layout**: complete. All widgets from the MATLAB app are recreated at the same geometry, with the same names. The original Filter, Threshold, and Make Masks sections (1-3) are commented out in `_create_components()` because the normal workflow uses the default adjustable polygon mask instead. Un-comment them to restore.
- **Polygon mask**: adjustable. Click and drag any orange vertex to reshape, drag inside to translate, right-click a vertex to delete, double-click an edge to insert a new vertex.
- **DICOM loading + display + radio toggle**: working.
- **Mask button** (Default + From File modes): working. See the note below on loading legacy `patient_roi.mat` files.
- **Analyze Depo**: working. Opens the masked deposition image and hot/cold map in separate windows, and prints the five summary statistics.
- **Get MCC, Export Data**, and the rest of the analysis callbacks: still stubbed. Each callback method references the line numbers of the original MATLAB source so the logic can be ported function by function.
- **Auxiliary analysis scripts** (`Process_New_Autoracked_VRPNs.m`, `Ensemble_Moduli_recursive_Waigh.m`, `Samplewise_Microviscosity.m`): not yet ported.

## Run from source

```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS / Linux:
source .venv/bin/activate

pip install -r requirements.txt
python MCC_Hot_Cold_GUI.py
```

Python 3.10 or newer is recommended.

If PySide6 fails to import with `DLL load failed while importing QtCore: The specified procedure could not be found.`, install the Visual C++ 2015-2022 x64 redistributable from <https://aka.ms/vs/17/release/vc_redist.x64.exe> and try again. The `diagnose.bat` script will tell you whether the redistributable is missing.

## Build a shareable single-file Windows .exe

The packaged executable is fully self-contained — recipients do not need Python, the venv, or any of the analysis libraries installed.

From cmd.exe in this folder:

```bat
build_exe.bat
```

From PowerShell in this folder:

```powershell
.\build_exe.ps1
```

Either script creates a clean virtual environment, installs `requirements.txt` plus `pyinstaller`, then runs PyInstaller against `MCC_Hot_Cold_GUI.spec`. Expect the build to take about 3 to 8 minutes the first time and produce `dist\MCC_Hot_Cold_GUI.exe` (roughly 200–300 MB; the bulk is PySide6, matplotlib, numpy, scipy, pydicom, openpyxl, and Pillow bundled together).

### What to share with recipients

Just the single `MCC_Hot_Cold_GUI.exe` from the `dist\` folder. Zip it and email or share it however you like — no other files are needed.

### Recipient prerequisites

A 64-bit Windows machine and the Microsoft Visual C++ 2015-2022 x64 redistributable. The redistributable ships with most modern Windows installations, but if a recipient sees `DLL load failed while importing QtCore: The specified procedure could not be found.` on first launch, point them to <https://aka.ms/vs/17/release/vc_redist.x64.exe>.

Recipients do not need a Python installation, do not need to install pip packages, and do not need to clone or download anything else.

### Antivirus / SmartScreen notes

Because PyInstaller-bundled `.exe` files extract a temp directory and load DLLs from it on startup, Windows SmartScreen sometimes shows an "unknown publisher" warning on first launch — recipients click "More info → Run anyway." This is normal for unsigned executables. If you plan to distribute widely, code-sign the `.exe` with an EV certificate; for a small group of collaborators the warning is harmless.

The `build_exe.spec` deliberately disables UPX compression — UPX makes the `.exe` smaller but occasionally triggers heuristic false positives in Windows Defender and other AV scanners. The trade-off is a slightly larger file in exchange for fewer support calls.

### Iterating

After your first build, you can rerun `build_exe.bat` / `build_exe.ps1` to rebuild. The scripts reuse the existing `.venv` (no re-install), so subsequent builds are faster — usually 1 to 3 minutes. Delete `.venv\` if you ever want to start from a clean Python install (e.g. after upgrading dependencies in `requirements.txt`).

## Build a shareable macOS .app

PyInstaller does **not** cross-compile — a macOS `.app` cannot be produced on a Windows or Linux machine. The two practical paths to a Mac build are:

### Path 1: build on any Mac

On the Mac, in this folder, in Terminal:

```bash
chmod +x build_app.sh    # first time only
./build_app.sh
```

The script creates `.venv`, installs `requirements.txt` plus `pyinstaller`, then builds `dist/MCC_Hot_Cold_GUI.app`. Drag the `.app` to `/Applications` to test, or run `open dist/MCC_Hot_Cold_GUI.app` from Terminal. Architecture matches the Mac that built it — an Apple Silicon Mac produces an arm64 `.app`, an Intel Mac produces an x86_64 `.app`.

### Path 2: GitHub Actions (no Mac required)

The repo includes `.github/workflows/build.yml`, which spins up a free macOS runner on every push and produces both Apple Silicon and Intel builds as downloadable artifacts. To use it: push the repo to GitHub, open the **Actions** tab, click the latest workflow run, and download `MCC_Hot_Cold_GUI-macos-arm64` and `MCC_Hot_Cold_GUI-macos-x86_64` from the **Artifacts** section. (The same workflow also produces the Windows `.exe`, so a single push gives you all three platforms.)

### Distributing via GitHub Releases (recommended for any non-trivial size)

For files too large to attach to email or Slack, GitHub Releases gives you a permanent download URL per file (up to 2 GB each, much larger than the ~300 MB our `.exe` lands at).

The repo's workflow auto-publishes a Release when you push a version tag. From the local clone:

```powershell
# Bump-and-tag a new version.  Any tag starting with "v" works.
git tag v1.0.0
git push origin v1.0.0
```

That single tag push triggers the Actions workflow to build Windows + both macOS architectures, then attaches the three files to a brand-new Release named `v1.0.0`:

- `MCC_Hot_Cold_GUI-windows.exe`
- `MCC_Hot_Cold_GUI-macos-arm64.app.zip`
- `MCC_Hot_Cold_GUI-macos-x86_64.app.zip`

Each file gets a stable URL of the form `https://github.com/USER/mcc_hot_cold_gui/releases/download/v1.0.0/MCC_Hot_Cold_GUI-windows.exe` that you can paste into emails, share over Teams, etc. Recipients click and it downloads in any browser — no GitHub knowledge required.

Release notes are auto-generated from the commit log since the last tag, so it's worth writing descriptive commit messages.

**Privacy caveat for private repos**: release-asset URLs from a *private* repo still require a recipient to sign into a GitHub account that has access to the repo. If your recipients won't have GitHub accounts, you have three options: (a) make the repo public (review the history first to be sure nothing sensitive landed in early commits), (b) host the artifacts on a different file-share like Dropbox/OneDrive, or (c) generate a short-lived signed URL per recipient — there's no built-in GitHub feature for this, so manual file-share is usually simpler.

### Sharing the `.app` (manual, smaller distributions)

Zip with the macOS-native tool to preserve extended attributes:

```bash
cd dist
ditto -c -k --sequesterRsrc --keepParent MCC_Hot_Cold_GUI.app MCC_Hot_Cold_GUI.app.zip
```

Send the `.zip`. On a recipient's Mac, double-clicking the unzipped `.app` will trigger Gatekeeper:

> "MCC_Hot_Cold_GUI.app" cannot be opened because the developer cannot be verified.

This is expected for unsigned apps. Have the recipient **right-click (or Control-click) the .app → Open → Open** in the security dialog. This is a one-time approval per Mac. If you plan to share widely or with hospitals/clinics that have stricter security policies, you'll need to code-sign and notarize through Apple — that requires a $99/year Apple Developer account.

## Basic usage

The GUI is split into two columns. The left column loads images and shows the canvas; the right column drives the analysis pipeline.

### 1. Load the three patient images

Use the three **Browse** buttons in the upper left to point the app at the patient's `BKG`, `Tx`, and `Scan Stack` DICOM files. The file you load last is shown on the canvas; switch among them later with the **Display** radio group (BKG / Tx / Deposition). The Scan Stack browser automatically advances the radio to "Deposition" so you can immediately mask the deposition image. The first folder you browse to becomes the default starting folder for the other browsers.

### 2. Apply the lung-region mask

The right column starts with **1. Mask RL**, the central interaction in this version of the app. Pick one of the two modes from the dropdown:

- **Default** draws a hardcoded 15-vertex lung-shaped polygon scaled to the current image size.
- **From File** loads a previously saved ROI from a `.mat` file (the MATLAB app's `patient_roi.mat` format) or a NumPy `.npy` Nx2 vertex array. If the text field is empty, you'll be prompted to pick a file; otherwise it loads from the path shown.

After pressing **Mask**, the polygon appears in blue with orange vertex handles. It is fully editable:

- Left-click and drag any orange handle to move that vertex.
- Left-click and drag inside the polygon to translate the whole shape.
- Right-click an orange handle to delete that vertex (minimum 3 kept).
- Double-click an edge to insert a new vertex at the click point.

Tick **Track** if you want any translation you apply to the mask to be applied to the Tx image during analysis. **Unmask** removes the overlay.

### 3. Analyze Depo (hot/cold analysis)

With BKG, Tx, and Scan Stack loaded and a mask on the canvas, press **2. Get Hot/Cold > Analyze Depo**. The app:

1. Subtracts the background median (computed from `BKGim / 7.5`) from both deposition and transmission images.
2. Gaussian-smooths each at sigma = 2.
3. Rasterizes the polygon to a binary lung mask.
4. Opens a popup window showing the masked deposition image.
5. Computes the hot/cold image as `(depo/depo_median) / (tx/tx_median)`, masked to the lung.
6. Opens a second popup with the hot/cold map drawn with the original 6-band black-blue-cyan-green-yellow-red colormap (range 0 to 2.5).
7. Computes the five summary stats: hot number ratio (pixels with value > 2 / lung pixel count), cold number ratio (< 0.5), hot sum ratio (deposition counts inside hot pixels / total deposition counts in lung), deposition skewness, and the central/peripheral counts ratio.
8. Shows the stats in a dialog and stores them in `self.HotColdData`.

Each popup window has a matplotlib toolbar so you can pan, zoom, and save the figure as PNG/PDF.

### 4. Reset / new scan

The **Reset / New Scan** button clears the canvas and every stored array so you can start over with a new patient without reopening the app.

## Note on loading legacy `patient_roi.mat` files

The MATLAB app saves the entire `images.roi.Polygon` *handle object*, not just the vertex array, with `save([app.SubDir,'\patient_roi.mat'],'lung_mask')`. SciPy can read the `.mat` container but cannot introspect MATLAB MCOS handle classes, so the `lung_mask` variable comes back as an opaque blob (a `MatlabOpaque` structured array with fields `s0`, `s1`, `s2`, `arr`).

The Python port handles this in three tiers:

1. `scipy.io.loadmat` reads the file. If it's MATLAB v7.3 (HDF5), the loader falls back to `h5py` automatically. Install it with `pip install h5py` if needed.
2. A recursive walker searches every variable for an Nx2 numeric array, preferring fields literally named `Position` or `Vertices`. This is enough for ROI files saved as a plain `struct`.
3. For the opaque-handle case, a byte scanner opens every `uint8` buffer it can reach (including the `arr` field of the MatlabOpaque) and pulls out the longest run of consecutive doubles that look like polygon vertices: finite, in the range -32 to 4096 pixels, with non-trivial spatial spread, and an even count.

### Failure mode and workaround

The byte scanner is heuristic. It is biased toward the longest plausible run and works on real `patient_roi.mat` files in testing, but it can occasionally:

- Pick up one or two extra "vertices" at the end of the polygon that are actually adjacent bytes happening to decode as in-range doubles. Right-click those orange handles to delete them after the polygon appears.
- Pick the wrong byte run if some unrelated array embedded in the same file is longer than the polygon and also happens to lie in pixel-coordinate range.
- Miss the polygon entirely if the file is MATLAB v7.3 *and* `h5py` is not installed (the error dialog will tell you to install it).

If the loader gives up entirely with "Could not find an Nx2 vertex array in the .mat file", the most reliable workaround is to re-export just the vertex array in MATLAB:

```matlab
load patient_roi.mat            % loads lung_mask
vertices = lung_mask.Position;  % Nx2 double
save patient_roi_pos.mat vertices
```

`patient_roi_pos.mat` will load cleanly through tier 2 of the loader (no byte scanning needed). The same workaround fixes the "extra vertex" or "wrong array" cases above.

If you prefer not to touch MATLAB, you can also save the polygon as `.npy` from inside the Python app once you have it on the canvas (planned addition).

## Porting the remaining callbacks

Every stubbed callback in `MCC_Hot_Cold_GUI.py` has a comment pointing to the MATLAB line number in `mlapp_extracted/extracted_matlab_code.m` (created by unzipping the original `.mlapp`). Suggested toolbox mappings:

| MATLAB toolbox          | Python equivalent                   |
|-------------------------|-------------------------------------|
| Image Processing        | `scikit-image`, `opencv-python`     |
| Signal Processing       | `scipy.signal`                      |
| Statistics & ML         | `scipy.stats`, `scikit-learn`       |
| Curve Fitting           | `scipy.optimize.curve_fit`, `lmfit` |
| DICOM I/O (`dicomread`) | `pydicom`                           |
| `images.roi.Polygon`    | `DraggablePolygon` (in this file)   |
| `imgaussfilt`           | `scipy.ndimage.gaussian_filter`     |
| `createMask`            | `matplotlib.path.Path.contains_points` |
| MATLAB `figure`         | `FigureWindow` (in this file)       |

## Troubleshooting

**DICOM could not decode pixel data (TransferSyntaxUID=...)** - the file is JPEG/JPEG2000/RLE-compressed. Install one or more of:

```bash
pip install pylibjpeg pylibjpeg-libjpeg pylibjpeg-openjpeg python-gdcm
```

**The interface looks tiny or oversized** - the GUI auto-scales from screen DPI on startup. Override with the environment variable `MCC_UI_SCALE`:

```bat
set MCC_UI_SCALE=1.6
python MCC_Hot_Cold_GUI.py
```

**A popup figure flashed and disappeared** - shouldn't happen now (popups are kept alive in a module-level list), but if it does, look for a real exception in the dialog the global error hook displays.
