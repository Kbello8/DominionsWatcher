@echo off
:: Dominions 6 Launcher - starts Dominions and the backup watcher together

cd /d "%~dp0"

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

:: Start the backup watcher in a separate window
start "Dom6 Backup Watcher" pythonw "%~dp0dom6_backup.py"

:: Launch Dominions
start "" "E:\SteamLibrary\steamapps\common\Dominions6\Dominions6.exe"

exit
