@echo off
:: Dominions 6 Save Backup Watcher - Launcher
:: Double-click this to start watching. Pick your game from the list.
:: Requires Python and watchdog: pip install watchdog

cd /d "%~dp0"
echo Starting Dominions 6 Backup Watcher...
echo.

:: Check Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python not found. Install from https://python.org
    pause
    exit /b 1
)

:: Install watchdog if missing
python -c "import watchdog" >nul 2>&1
if errorlevel 1 (
    echo Installing watchdog...
    pip install watchdog
)

python dom6_backup.py %*
pause
