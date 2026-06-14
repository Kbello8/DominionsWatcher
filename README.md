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

- **Windows**: Windows 10 or 11
- **macOS**: macOS 10.15 (Catalina) or later
- [Python 3](https://www.python.org/downloads/) installed (Windows: check "Add Python to PATH" during install; macOS: comes pre-installed or install via Homebrew)
- Dominions 6 on Steam


## Setup (Windows)

**1. Install the watchdog package**

Open Command Prompt and run:
```
pip install watchdog
```

**2. Create the shortcut**

Run `setup.bat`. It creates `Dominions6.lnk` in the same folder.

Then right-click `Dominions6.lnk` and choose "Pin to taskbar".

**3. First launch**

Click the taskbar icon. A window will appear asking for the path to the **Dominions 6 executable** (not the savedgames folder). This is what the script launches when you click the shortcut. Example:
```
E:\SteamLibrary\steamapps\common\Dominions6\Dominions6.exe
```

To find the path: right-click Dominions 6 in Steam, go to Manage, then Browse local files. Copy the path from the Explorer address bar and add `\Dominions6.exe` at the end.

The path is saved in `dom6_config.txt` next to the scripts. You will not be asked again.

The savedgames folder (`%APPDATA%\Dominions6\savedgames`) is detected automatically — you do not need to configure it.


## Setup (macOS)

**1. Install the watchdog package**

Open Terminal and run:
```
pip3 install watchdog
```

**2. Create the shortcut**

Run `setup.sh` in Terminal:
```
./setup.sh
```

This creates `Dominions6.command` in the same folder. Drag it to your Dock for quick access.

**3. First launch**

Double-click the Dock shortcut (or run `./dom6_launch.sh`). You'll be prompted for the path to the **dom6_mac executable** (not the savedgames folder). This is what the script launches when you click the shortcut. Example:
```
~/Library/Application Support/Steam/steamapps/common/Dominions6/dom6_mac
```

To find the path: right-click Dominions 6 in Steam, go to Manage, then Browse local files. A Finder window opens showing the game folder. The executable is called `dom6_mac`.

The path is saved in `dom6_config.txt` next to the scripts. You will not be asked again.

The savedgames folder (`~/.dominions6/savedgames`) is detected automatically — you do not need to configure it.


## Normal use

Just launch the game from your shortcut. The backup watcher starts automatically in the background and stops when you close the game.

To check if backups are happening, open the log file:
- **Windows**: `%APPDATA%\Dominions6\savedgames\dom6_backup.log`
- **macOS**: `~/.dominions6/savedgames/dom6_backup.log`


## Stopping the watcher manually

- **Windows**: Run `dom6_kill.bat`
- **macOS**: Run `./dom6_kill.sh`

This kills all running watcher instances regardless of how they were started.


## Files

| File | Purpose |
|------|---------|
| `setup.bat` | (Windows) Creates `Dominions6.lnk` shortcut |
| `setup.sh` | (macOS) Creates `Dominions6.command` shortcut |
| `dom6_launch.bat` | (Windows) Starts the game and the watcher |
| `dom6_launch.sh` | (macOS) Starts the game and the watcher |
| `dom6_backup.py` | The watcher script (cross-platform, runs in the background) |
| `dom6_backup.bat` | (Windows) Run the watcher standalone |
| `dom6_backup.sh` | (macOS) Run the watcher standalone |
| `dom6_kill.bat` | (Windows) Emergency stop for the watcher |
| `dom6_kill.sh` | (macOS) Emergency stop for the watcher |
| `dom6_config.txt` | Your saved game path (created on first run) |
