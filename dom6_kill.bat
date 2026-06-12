@echo off
:: Kills ALL running dom6_backup watcher instances (any python/pythonw process
:: whose command line references dom6_backup.py), then removes the lock file.

set "LOCK_FILE=%APPDATA%\Dominions6\savedgames\dom6_backup.lock"

echo Stopping all dom6_backup watchers...
powershell -NoProfile -Command "$found = $false; Get-CimInstance Win32_Process | Where-Object { $_.Name -like 'python*' -and $_.CommandLine -match 'dom6_backup' } | ForEach-Object { $found = $true; Write-Host ('Stopping watcher PID ' + $_.ProcessId); Stop-Process -Id $_.ProcessId -Force }; if (-not $found) { Write-Host 'No running watchers found.' }"

if exist "%LOCK_FILE%" (
    del "%LOCK_FILE%" >nul 2>&1
    if exist "%LOCK_FILE%" (
        echo WARNING: could not delete lock file: "%LOCK_FILE%"
    ) else (
        echo Lock file removed.
    )
)

echo Done.
pause
