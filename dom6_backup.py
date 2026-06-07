# Dominions 6 - Auto Save Backup Watcher
# Watches ALL game folders for order changes and maintains one backup folder per turn.
# Usage: python dom6_backup.py
# Requirements: pip install watchdog
#
# -----------------------------------------------------------------------------
# WHAT THE DOMINIONS SAVE FILES ACTUALLY ARE
# -----------------------------------------------------------------------------
# A game folder under \savedgames\<gamename>\ contains a few file types:
#
#   .2h        Your ORDERS file ("two hands"). One per player. Holds the commands
#              you've issued this turn (movements, spells, recruitment, etc.).
#              This changes EVERY time you tweak and re-save the same turn.
#              We trigger on this file so every order save is captured.
#
#   .trn       The TURN file the host sends you: the resolved game state for this
#              turn. Stable WITHIN a turn; changes when the host advances the game.
#              We hash it to identify which turn is active. Same hash = same turn
#              (orders re-save -> overwrite existing backup). New hash = turn
#              advanced -> create a new numbered backup folder.
#
#   ftherlnd   The master game-state file (host's authoritative record). Copied as
#              part of the backup, but not used to trigger one.
#
# BACKUP STRUCTURE
#   savedgames\
#     <gamename>\                  <- live game (watched)
#     <gamename>_backups\          <- backup container (ignored by watcher)
#       turn_index.json            <- maps trn-hash -> turn number (survives restarts)
#       <gamename>_001\            <- turn 1 backup
#       <gamename>_002\            <- turn 2 backup
#       <gamename>_003\            <- turn 3 backup (latest orders)
# -----------------------------------------------------------------------------
import json
import shutil
import time
import os
import sys
import atexit
import hashlib
import threading
import subprocess
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

SAVEDGAMES_PATH = Path(os.environ["APPDATA"]) / "Dominions6" / "savedgames"
EXCLUDE_EXTENSIONS = {".d6m", ".map"}

# Seconds to wait after the LAST detected change before backing up. Rapid saves
# keep pushing this out, so a burst collapses into a single backup.
BACKUP_DELAY = 10

# Marker file written into each <gamename>_backups\ container so the watcher
# can instantly identify and ignore those folders.
CONTAINER_MARKER = ".dom6bak_container"

LOCK_FILE = SAVEDGAMES_PATH / "dom6_backup.lock"


def is_pid_running(pid):
    result = subprocess.run(
        ["tasklist", "/FI", "PID eq " + str(pid)],
        capture_output=True, text=True
    )
    return str(pid) in result.stdout


def acquire_lock():
    if LOCK_FILE.exists():
        try:
            pid = int(LOCK_FILE.read_text().strip())
            if is_pid_running(pid):
                print("Watcher already running (PID " + str(pid) + "). Exiting.")
                sys.exit(0)
            else:
                print("Stale lock file found. Overwriting.")
        except ValueError:
            print("Invalid lock file. Overwriting.")
    LOCK_FILE.write_text(str(os.getpid()))
    atexit.register(release_lock)


def release_lock():
    if LOCK_FILE.exists():
        LOCK_FILE.unlink()


def is_backup_container(name):
    return (SAVEDGAMES_PATH / name / CONTAINER_MARKER).exists()


def copy_ignore(directory, contents):
    return [f for f in contents if Path(f).suffix in EXCLUDE_EXTENSIONS]


def trn_fingerprint(game_dir):
    # Hash of all .trn files (name + bytes), sorted for determinism. Returns None
    # if there are no .trn files yet (folder mid-write or not a real game).
    trns = sorted(game_dir.glob("*.trn"))
    if not trns:
        return None
    h = hashlib.sha256()
    for p in trns:
        try:
            h.update(p.name.encode("utf-8"))
            h.update(p.read_bytes())
        except OSError:
            return None  # being written right now; skip this cycle
    return h.hexdigest()


def load_index(index_file):
    if index_file.exists():
        try:
            return json.loads(index_file.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return {}
    return {}


def save_index(index_file, index):
    index_file.write_text(json.dumps(index, indent=2), encoding="utf-8")


class SaveWatcher(FileSystemEventHandler):
    def __init__(self):
        self._lock = threading.Lock()
        self._timers = {}  # game_name -> pending threading.Timer

    # Funnel every relevant event type through one handler. Saves that write a
    # temp file then rename it surface as created/moved, not just modified.
    def on_modified(self, event):
        if not event.is_directory:
            self._handle(event.src_path)

    def on_created(self, event):
        if not event.is_directory:
            self._handle(event.src_path)

    def on_moved(self, event):
        if not event.is_directory:
            self._handle(event.dest_path)

    def _handle(self, path_str):
        path = Path(path_str)
        if path.suffix != ".2h":
            return
        try:
            rel = path.relative_to(SAVEDGAMES_PATH)
        except ValueError:
            return
        if not rel.parts:
            return
        game_name = rel.parts[0]

        if is_backup_container(game_name):
            return  # change is inside a backup container; ignore

        # Debounce: each change reschedules the timer, so we fire once writes
        # settle. Non-blocking -- the observer thread is never tied up.
        with self._lock:
            existing = self._timers.get(game_name)
            if existing is not None:
                existing.cancel()
            timer = threading.Timer(BACKUP_DELAY, self._do_backup, args=(game_name,))
            self._timers[game_name] = timer
            timer.start()
        print("[" + time.strftime("%H:%M:%S") + "] Orders changed in '" + game_name +
              "' -- backup in " + str(BACKUP_DELAY) + "s...")

    def _do_backup(self, game_name):
        with self._lock:
            self._timers.pop(game_name, None)

        game_dir = SAVEDGAMES_PATH / game_name
        if not game_dir.is_dir():
            return

        fp = trn_fingerprint(game_dir)
        if fp is None:
            print("[" + time.strftime("%H:%M:%S") + "] '" + game_name +
                  "' no .trn found -- skipping.")
            return

        try:
            self._make_backup(game_dir, game_name, fp)
        except Exception as e:
            print("  ERROR during backup: " + str(e))

    def _make_backup(self, game_dir, game_name, fp):
        container = SAVEDGAMES_PATH / (game_name + "_backups")
        index_file = container / "turn_index.json"

        # Create container if needed; write marker first so watcher ignores it
        # immediately, before any game files land inside.
        if not container.exists():
            container.mkdir()
            (container / CONTAINER_MARKER).write_text("dom6 backup container")

        # Load hash -> turn_number map
        index = load_index(index_file)

        if fp in index:
            turn_num = index[fp]
            is_overwrite = True
        else:
            turn_num = max(index.values(), default=0) + 1
            index[fp] = turn_num
            is_overwrite = False

        dest = container / (game_name + "_" + str(turn_num).zfill(3))

        if is_overwrite and dest.exists():
            shutil.rmtree(dest)
        shutil.copytree(game_dir, dest, ignore=copy_ignore)

        # Persist updated index only after the copy succeeds
        save_index(index_file, index)

        action = "overwritten (same turn)" if is_overwrite else "created (new turn)"
        print("[" + time.strftime("%H:%M:%S") + "] Backup " + action +
              ": " + dest.name + "  [" + game_name + "_backups]")

    def cancel_all(self):
        with self._lock:
            for t in self._timers.values():
                t.cancel()
            self._timers.clear()


def main():
    if not SAVEDGAMES_PATH.exists():
        print("ERROR: savedgames folder not found: " + str(SAVEDGAMES_PATH))
        sys.exit(1)
    acquire_lock()
    print("Watching all games in: " + str(SAVEDGAMES_PATH))
    print("Backups stored in:     <gamename>_backups\\ (one numbered folder per turn)")
    print("Delay: " + str(BACKUP_DELAY) + "s after last order change.")
    print("Press Ctrl+C to stop.\n")

    handler = SaveWatcher()
    observer = Observer()
    observer.schedule(handler, str(SAVEDGAMES_PATH), recursive=True)
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nStopping watcher.")
        handler.cancel_all()
        observer.stop()
    observer.join()


if __name__ == "__main__":
    main()
