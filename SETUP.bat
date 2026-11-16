@echo off
setlocal enableextensions
cd /d "%~dp0"
echo ==================================================================
echo   PROJECT SETUP  (this can take several minutes the first time)
echo ==================================================================
echo.

echo [1/8] Looking for Python...
set "PY="
where py >nul 2>nul && py -3 --version >nul 2>nul && set "PY=py -3"
if not defined PY (
  where python >nul 2>nul && python --version >nul 2>nul && set "PY=python"
)
if not defined PY goto :nopython

echo [2/8] Checking the Python version...
%PY% --version
%PY% -c "import sys; sys.exit(0 if sys.version_info>=(3,9) else 1)"
if errorlevel 1 goto :oldpython

echo [3/8] Creating the virtual environment (.venv)...
if exist ".venv\Scripts\python.exe" (
  echo       .venv already exists - reusing it.
) else (
  %PY% -m venv .venv
  if errorlevel 1 goto :venvfail
)

echo [4/8] Activating the environment...
call ".venv\Scripts\activate.bat"
if errorlevel 1 goto :venvfail

echo [5/8] Upgrading pip...
python -m pip install --upgrade pip
if errorlevel 1 echo       WARNING: could not upgrade pip - continuing.

echo [6/8] Installing required libraries (needs internet)...
python -m pip install -r requirements.txt
if errorlevel 1 goto :pipfail
echo       Installing optional libraries (XGBoost, SHAP) - failures here are OK...
python -m pip install -r requirements-optional.txt
if errorlevel 1 echo       NOTE: optional libraries were not installed. The project still works without them.

echo [7/8] Checking that the essential libraries work...
python -m src.env_check
if errorlevel 1 goto :checkfail

echo [8/8] Creating folders...
if not exist "data\downloads" mkdir "data\downloads"
if not exist "data\tmp" mkdir "data\tmp"
if not exist "output" mkdir "output"

echo.
echo ==================================================================
echo   SETUP SUCCEEDED
echo ==================================================================
echo Next step:
echo   - Double-click RUN_PROJECT.bat
echo   - or, in the VS Code terminal, type:  python main.py
echo   - To just test the software first:    python main.py --synthetic
echo.
pause
exit /b 0

:nopython
echo.
echo SETUP FAILED: Python was not found.
echo What to do: install Python 3.9 or newer from https://www.python.org/downloads/
echo   IMPORTANT: on the first installer screen tick "Add python.exe to PATH".
echo Then close this window and double-click SETUP.bat again.
pause
exit /b 1

:oldpython
echo.
echo SETUP FAILED: your Python is too old (3.9 or newer is needed).
echo What to do: install a newer Python from https://www.python.org/downloads/ and run SETUP.bat again.
pause
exit /b 1

:venvfail
echo.
echo SETUP FAILED: could not create or activate the virtual environment.
echo What to do: close VS Code and other programs using this folder, delete the ".venv" folder if it exists,
echo and run SETUP.bat again. If it still fails, check you have write permission in this folder.
pause
exit /b 1

:pipfail
echo.
echo SETUP FAILED: installing the libraries failed.
echo What to do: check your internet connection (and any VPN/proxy), then run SETUP.bat again.
echo The messages above show which library failed.
pause
exit /b 1

:checkfail
echo.
echo SETUP FAILED: the libraries installed but did not pass the check above.
echo What to do: run SETUP.bat once more. If it repeats, send the messages above to whoever is helping you.
pause
exit /b 1
