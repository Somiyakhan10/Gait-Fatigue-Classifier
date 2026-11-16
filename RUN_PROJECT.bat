@echo off
setlocal enableextensions
cd /d "%~dp0"
echo ==================================================================
echo   RUNNING THE RESEARCH PIPELINE
echo ==================================================================
if not exist ".venv\Scripts\activate.bat" (
  echo The environment is not set up yet. Please double-click SETUP.bat first.
  pause
  exit /b 1
)
call ".venv\Scripts\activate.bat"
echo Checking required libraries...
python -m src.env_check
if errorlevel 1 (
  echo Some libraries are missing. Please double-click SETUP.bat to repair the installation.
  pause
  exit /b 1
)
echo.
echo Starting. Real data is downloaded automatically (needs internet). Progress is shown below.
echo Extra options can be added when starting from a terminal, for example:  RUN_PROJECT.bat --synthetic
echo.
python main.py %*
set "RC=%errorlevel%"
echo.
if not "%RC%"=="0" goto :problems
echo FINISHED SUCCESSFULLY. Results are in the "output" folder inside this project folder.
echo The final report path is printed above - look for "final report".
pause
exit /b 0

:problems
echo FINISHED WITH PROBLEMS - code %RC%. Please read the messages above. Nothing was faked.
pause
exit /b %RC%
