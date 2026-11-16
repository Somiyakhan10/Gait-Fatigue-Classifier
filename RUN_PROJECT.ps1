# Run with:  powershell -ExecutionPolicy Bypass -File .\RUN_PROJECT.ps1 [options]
Set-Location -Path $PSScriptRoot
Write-Host "RUNNING THE RESEARCH PIPELINE" -ForegroundColor Cyan
$venvPy = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $venvPy)) {
    Write-Host "The environment is not set up yet. Please double-click SETUP.bat first." -ForegroundColor Red
    exit 1
}
$activate = Join-Path $PSScriptRoot ".venv\Scripts\Activate.ps1"
if (Test-Path $activate) { . $activate }
& $venvPy -m src.env_check
if ($LASTEXITCODE -ne 0) {
    Write-Host "Some libraries are missing. Please double-click SETUP.bat to repair the installation." -ForegroundColor Red
    exit 1
}
& $venvPy main.py @args
$rc = $LASTEXITCODE
if ($rc -eq 0) {
    Write-Host "FINISHED SUCCESSFULLY. Results are in: $(Join-Path $PSScriptRoot 'output')" -ForegroundColor Green
} else {
    Write-Host "FINISHED WITH PROBLEMS (code $rc). Please read the messages above - nothing was faked." -ForegroundColor Yellow
}
exit $rc
