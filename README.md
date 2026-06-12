# Dominions 6 Auto-Backup

Automatically backs up your game turns in the background while you play. Every time you save your orders, a backup is created. When the host advances the game, a new numbered backup folder appears. When you close Dominions, the watcher shuts itself down.

No manual steps once it is running.


## What gets backed up

For each game, backups are stored in your Dominions saved games folder:

```
Dominions6\savedgames\
  YourGame\             <- your live game (unchanged)
  YourGame_backups\
    YourGame_001\       <- turn 1
    YourGame_002\       <- turn 2
    YourGame_003\       <- turn 3 (latest)
```

Re-saving the same turn overwrites the existing backup instead of creating a new folder. New turn from the host creates a new numbered folder.


## Requirements

- Windows 10 or 11
- [Python 3](https://www.python.org/downloads/) installed (check "Add Python to PATH" during install)
- Dominions 6 on Steam


## Setup

**1. Install the watchdog package**

Open Command Prompt and run:
```
pip install watchdog
```

**2. Pin the shortcut to your taskbar**

Right-click `Dominions6.lnk` and choose "Pin to taskbar".

**3. First launch**

Click the taskbar icon. A window will appear asking for the path to your Dominions6.exe, something like:
```
E:\SteamLibrary\steamapps\common\Dominions6\Dominions6.exe
```

To find the path: right-click Dominions 6 in Steam, go to Manage, then Browse local files. Copy the path from the Explorer address bar and add `\Dominions6.exe` at the end.

The path is saved in `dom6_config.txt` next to the scripts. You will not be asked again.


## Normal use

Just launch the game from the taskbar shortcut. The backup watcher starts automatically in the background and stops when you close the game.

To check if backups are happening, open:
```
%APPDATA%\Dominions6\savedgames\dom6_backup.log
```


## Stopping the watcher manually

Run `dom6_kill.bat`. This kills all running watcher instances regardless of how they were started.


## Files

| File | Purpose |
|------|---------|
| `Dominions6.lnk` | Taskbar shortcut, the only thing you need to click |
| `dom6_launch.bat` | Launched by the shortcut; starts the game and the watcher |
| `dom6_backup.py` | The watcher script (runs in the background) |
| `dom6_kill.bat` | Emergency stop for the watcher |
| `dom6_config.txt` | Your saved game path (created on first run) |
