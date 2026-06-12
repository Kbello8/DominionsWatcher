@echo off
:: Creates Dominions6.lnk shortcut in the same folder, pointing at dom6_launch.bat

cd /d "%~dp0"

set "SHORTCUT=%~dp0Dominions6.lnk"
set "TARGET=%~dp0dom6_launch.bat"

powershell -NoProfile -Command ^
  "$ws = New-Object -ComObject WScript.Shell; ^
   $s = $ws.CreateShortcut('%SHORTCUT%'); ^
   $s.TargetPath = '%TARGET%'; ^
   $s.WorkingDirectory = '%~dp0'; ^
   $s.Description = 'Launch Dominions 6 with auto-backup'; ^
   $s.Save()"

if exist "%SHORTCUT%" (
    echo Shortcut created: %SHORTCUT%
    echo Right-click it and choose "Pin to taskbar".
) else (
    echo ERROR: Shortcut creation failed.
)
pause
