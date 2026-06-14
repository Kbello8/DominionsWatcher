#!/bin/bash
# Dominions 6 Save Backup Watcher - Launcher (macOS)
# Run this to start watching without launching the game.
# Requires Python 3 and watchdog: pip3 install watchdog

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Starting Dominions 6 Backup Watcher..."
echo ""

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

python3 "$SCRIPT_DIR/dom6_backup.py" "$@"
