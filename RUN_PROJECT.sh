#!/usr/bin/env bash
# macOS / Linux launcher:  bash RUN_PROJECT.sh [options]
cd "$(dirname "$0")" || exit 1
PY=$(command -v python3 || command -v python)
if [ -z "$PY" ]; then echo "Python 3.9+ was not found. Please install it first."; exit 1; fi
if [ ! -d .venv ]; then
  echo "First run: creating the virtual environment and installing libraries (needs internet)..."
  "$PY" -m venv .venv || { echo "Could not create .venv"; exit 1; }
  # shellcheck disable=SC1091
  . .venv/bin/activate
  python -m pip install --upgrade pip && python -m pip install -r requirements.txt || { echo "Library installation failed. Check your internet connection."; exit 1; }
  python -m pip install -r requirements-optional.txt || echo "Optional libraries (XGBoost/SHAP) not installed - continuing without them."
else
  # shellcheck disable=SC1091
  . .venv/bin/activate
fi
python -m src.env_check || { echo "Libraries missing. Delete the .venv folder and run again."; exit 1; }
python main.py "$@"
rc=$?
if [ $rc -eq 0 ]; then echo "FINISHED SUCCESSFULLY. Results are in: $(pwd)/output"; else echo "FINISHED WITH PROBLEMS (code $rc). Please read the messages above - nothing was faked."; fi
exit $rc
