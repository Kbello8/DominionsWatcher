#!/bin/bash
# Dominions 6 Launcher (macOS) - starts Dominions and the backup watcher together
# Game app path is stored in dom6_config.txt (prompted on first run).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/dom6_config.txt"

# Check Python is available
if ! command -v python3 &>/dev/null; then
    echo "ERROR: Python 3 not found. Install from https://python.org or via Homebrew: brew install python"
    exit 1
fi

# Install watchdog if missing
if ! python3 -c "import watchdog" &>/dev/null; then
    echo "Installing watchdog..."
    pip3 install watchdog
fi

# Load configured game path, or prompt and persist on first run
GAME_PATH=""
if [ -f "$CONFIG_FILE" ]; then
    GAME_PATH="$(cat "$CONFIG_FILE")"
fi

prompt_path() {
    echo ""
    echo "Enter full path to the dom6_mac executable:"
    echo "  e.g. ~/Library/Application Support/Steam/steamapps/common/Dominions6/dom6_mac"
    read -r GAME_PATH
    # Strip quotes if user pasted them
    GAME_PATH="${GAME_PATH//\"/}"
    # Expand tilde
    GAME_PATH="${GAME_PATH/#\~/$HOME}"
    if [ ! -e "$GAME_PATH" ]; then
        echo "ERROR: Not found: $GAME_PATH"
        prompt_path
        return
    fi
    echo "$GAME_PATH" > "$CONFIG_FILE"
}

if [ -z "$GAME_PATH" ] || [ ! -e "$GAME_PATH" ]; then
    if [ -n "$GAME_PATH" ]; then
        echo "Configured game path no longer exists: $GAME_PATH"
    fi
    prompt_path
fi

# Start the backup watcher in the background; it exits when the game closes
nohup python3 "$SCRIPT_DIR/dom6_backup.py" --follow-game >/dev/null 2>&1 &
disown

# Launch Dominions
"$GAME_PATH" &
disown
exit 0
