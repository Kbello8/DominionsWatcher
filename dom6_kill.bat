@echo off
:: Kills any running dom6_backup watcher instances

set LOCK_FILE=%APPDATA%\Dominions6\savedgames\dom6_backup.lock

if not exist "%LOCK_FILE%" (
    echo No watcher lock file found. Watcher may not be running.
    goto end
)

set /p PID=<"%LOCK_FILE%"
echo Found watcher PID: %PID%

taskkill /PID %PID% /F >nul 2>&1
if errorlevel 1 (
    echo Process not found. Cleaning up stale lock file.
) else (
    echo Watcher stopped.
)

del "%LOCK_FILE%" >nul 2>&1

:end
pause
