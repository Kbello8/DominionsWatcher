@echo off
:: Dominions 6 Launcher - starts Dominions and the backup watcher together
:: Game exe path is stored in dom6_config.txt (prompted on first run).

cd /d "%~dp0"

set "CONFIG_FILE=%~dp0dom6_config.txt"
set "GAME_PATH="

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

:: Load configured game path, or prompt and persist on first run
if exist "%CONFIG_FILE%" set /p GAME_PATH=<"%CONFIG_FILE%"
if not defined GAME_PATH goto prompt
if not exist "%GAME_PATH%" (
    echo Configured game path no longer exists: "%GAME_PATH%"
    goto prompt
)
goto launch

:prompt
echo.
set /p GAME_PATH=Enter full path to Dominions6.exe:
set "GAME_PATH=%GAME_PATH:"=%"
if not exist "%GAME_PATH%" (
    echo ERROR: File not found: "%GAME_PATH%"
    goto prompt
)
>"%CONFIG_FILE%" echo %GAME_PATH%

:launch
:: Start the backup watcher in the background; it exits when the game closes
start "Dom6 Backup Watcher" pythonw "%~dp0dom6_backup.py" --follow-game

:: Launch Dominions
start "" "%GAME_PATH%"

exit
