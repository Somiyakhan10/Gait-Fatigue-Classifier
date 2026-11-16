# Machine Learning and Nonlinear Time-Series Analysis for Predicting Fatigue-Related Changes in Human Movement

A ready-to-run Python project. It downloads real public gait data, computes conventional and nonlinear features
(Sample Entropy, Recurrence Quantification Analysis, Lyapunov exponent, Detrended Fluctuation Analysis), compares
machine-learning models with leave-one-subject-out validation, explains them (permutation importance and SHAP) and
writes figures, tables and a Markdown report into `output/`.

**New to this? Read `INSTALLATION_GUIDE.md` (Windows + VS Code, step by step).**

## Quick start (Windows)
1. Extract the ZIP, open the folder in VS Code (File -> Open Folder).
2. Double-click `SETUP.bat` and wait until it says SETUP SUCCEEDED.
3. Double-click `RUN_PROJECT.bat` (or type `python main.py` in the VS Code terminal after the setup).
4. Open the `output` folder. Start with `output/real/<dataset>/report.md`.

macOS/Linux: `bash RUN_PROJECT.sh`.

## Commands
| Command | What it does |
|---|---|
| `python main.py` | real-data analysis of the datasets listed in `config/config.yaml` |
| `python main.py --synthetic` | clearly-labelled simulated demo (tests the software; NOT findings) |
| `python main.py --datasets umwdb` | one real dataset (`umwdb`, `duo_gait`, `duo_gait_raw`, `local_folder`) |
| `python main.py --experiment nonlinear` | only one feature set: `conventional`, `nonlinear`, `hybrid` or `all` |
| `python main.py --models RandomForest SVM` | only some models |
| `python main.py --inspect duo_gait` | look inside a dataset (file names, columns) |
| `python main.py --check` / `--run-tests` | check the installation / run all tests |
| `python main.py --generate-key`, `--encrypt-folder SRC DEST`, `--decrypt-file F OUT` | AES-256-GCM encryption |
| `python main.py --config experiments/quick_check.yaml` | faster preset (see `experiments/`) |
| `--refresh`, `--keep-raw`, `--no-cleanup`, `--yes`, `--export-zip`, `--debug` | recompute / keep downloads / keep temp files / allow big downloads / zip results / technical errors |

## What gets produced (`output/real/<dataset>/`)
`report.md` (final report), `dataset_information.md`, `tables/` (data quality, preprocessing, conventional features,
SampEn, RQA, Lyapunov, DFA, model comparison, participant-level validation, importance, SHAP), `figures/` (300-dpi PNG),
`features.csv`, `model_hybrid_rf.joblib`. Simulated results are kept apart in `output/synthetic/`.

## Honesty rules built into the code
- Real data is never silently replaced by synthetic data. If a download fails you get a plain explanation and nothing else is produced.
- "Fatigue" is only claimed where a dataset has fatigue labels. `umwdb` has none (task: spontaneous vs paced walking).
- Synthetic results carry a banner and live in a separate folder.
- Temporary files are deleted after a successful run; your own data is never deleted or modified.
- Optional packages (XGBoost, SHAP) can be missing: the project says so and continues.

## Layout
`config/` settings and dataset registry | `src/data/` download, extraction, storage, temp files | `src/features/` conventional and nonlinear
features | `src/models.py` experiments | `src/security/` encryption | `experiments/` presets | `notebooks/colab_run.ipynb` Google Colab |
`tests/` automated tests | `data/` and `output/` working folders.

## Datasets and limits
See `DATASET_GUIDE.md`. Cloud option: `CLOUD_PROCESSING_GUIDE.md`. Re²Load data are not public: if you are given authorised access, put the
files in a folder and use the `local_folder` entry (optionally encrypted, see below).

## Encrypting sensitive data (AES-256-GCM)
1. `python main.py --generate-key` creates a key in your home folder (`~/.gait_project/keys/`), outside the project and ZIP. **Back it up.**
2. `python main.py --encrypt-folder "C:\path\to\data" data\private` writes encrypted `.enc` copies (originals untouched; delete them yourself after checking).
3. In `config/datasets.yaml` under `local_folder`: set `path: data/private`, `encrypted: true`, your `subject_regex`, `label_rules`, `fs`, and in `config/config.yaml` set `datasets: [local_folder]`.
4. `python main.py` decrypts each file only into a temporary folder, analyses it, and wipes it immediately. Only derived features are saved.
Keys are never printed or stored in the project. Files are authenticated: a wrong key or modified file is rejected.
Limits: wiping is best-effort (not guaranteed on SSDs or cloud-synced folders); results/features are not encrypted.
