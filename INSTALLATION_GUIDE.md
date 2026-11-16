# Installation Guide (Windows + VS Code, no programming needed)

## Before you start
- Windows 10/11 and an internet connection (needed once for setup and for downloading data).
- Python 3.9 or newer. If you do not have it: download from https://www.python.org/downloads/ and, on the first installer
  screen, **tick "Add python.exe to PATH"**. (`SETUP.bat` tells you if Python is missing.)
- VS Code (https://code.visualstudio.com/) with the "Python" extension (VS Code will offer it).

## Steps
1. **Download** the ZIP.
2. **Extract** it (right-click -> Extract All) to a folder such as `C:\Projects\gait_project`. Avoid OneDrive/Desktop-synced folders if you can.
3. **Open VS Code.**
4. **File -> Open Folder**, choose the extracted folder. Click "Yes, I trust the authors".
5. **Double-click `SETUP.bat`** (in File Explorer, or right-click it in VS Code -> Reveal in File Explorer).
6. **Wait** until it prints `SETUP SUCCEEDED` (several minutes the first time). If it prints an error it says what to do.
7. **Double-click `RUN_PROJECT.bat`**, or in VS Code open Terminal -> New Terminal and type `python main.py`.
   (If `python` is not recognised in that terminal, use `.venv\Scripts\python.exe main.py`, or press Ctrl+Shift+P -> "Python: Select Interpreter" -> choose the one in `.venv`.)
8. **Open the `output` folder.** The final report is `output\real\<dataset>\report.md` (the program prints the exact path).

Optional: Terminal -> Run Task... offers the same actions (setup, run, synthetic demo, tests, inspect, check).

## Test the software first (no internet needed for the run itself)
`python main.py --synthetic` -> simulated demo in `output\synthetic\SYNTHETIC_DEMO`. It proves the software works; it is **not** a research result.

## What to expect on a real run
The program downloads small real datasets (about 1 MB and 2.6 MB), checks them, extracts and analyses them in a temporary folder, saves
the results and deletes the temporary files. Large files ask for permission first.
If it says a dataset could not be downloaded or the files do not look as expected, nothing is faked:
- No internet / blocked website: connect or try another network, or use Google Colab (`CLOUD_PROCESSING_GUIDE.md`).
- DUO-GAIT file names/columns differ from the settings: run `python main.py --inspect duo_gait`, then edit `config\datasets.yaml`
  (`subject_regex`, `label_rules`, `columns`, `fs`). See `DATASET_GUIDE.md`.

## Common problems
| Message | Fix |
|---|---|
| "Python was not found" | install Python and tick "Add to PATH", rerun `SETUP.bat` |
| "installing the libraries failed" | check internet/VPN, rerun `SETUP.bat` |
| PowerShell says scripts are disabled | use the `.bat` files, or `powershell -ExecutionPolicy Bypass -File .\RUN_PROJECT.ps1` |
| Windows SmartScreen warning on the `.bat` | click "More info" -> "Run anyway" (the scripts are plain text you can read) |
| Not enough disk space | the program checks first; free space or use Colab |

## Is there a web app?
No. If you were told to run `streamlit run src/app.py`: that does not exist in this project and is not needed. Use `python main.py`; results are files in `output/`.

## Tests
`python main.py --run-tests` (or `python -m pytest tests -v`).

## Status of testing (honest)
The PhysioNet (`umwdb`) real-data run was confirmed working on the user's own Windows PC. DUO-GAIT is not confirmed yet: its folder names and columns were inferred from a failed run, and the code was tested only on a simulated archive with that layout.

The tests, the synthetic demo, the encryption, cleanup, download/extraction logic (against a local test server) and the `.sh` launcher were
run on Linux. The Windows `.bat`/`.ps1` scripts were written carefully but **could not be executed** in the build environment, and the real
datasets could not be downloaded there, so real-data runs are untested. See `DATASET_GUIDE.md`.
