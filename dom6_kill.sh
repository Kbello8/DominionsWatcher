#!/bin/bash
# Kills ALL running dom6_backup watcher instances (any python process
# whose command line references dom6_backup), then removes the lock file.

LOCK_FILE="$HOME/.dominions6/savedgames/dom6_backup.lock"

echo "Stopping all dom6_backup watchers..."

PIDS=$(pgrep -f "dom6_backup")
if [ -n "$PIDS" ]; then
    echo "$PIDS" | while read -r pid; do
        echo "Stopping watcher PID $pid"
        kill "$pid" 2>/dev/null
    done
else
    echo "No running watchers found."
fi

if [ -f "$LOCK_FILE" ]; then
    rm -f "$LOCK_FILE"
    if [ -f "$LOCK_FILE" ]; then
        echo "WARNING: could not delete lock file: $LOCK_FILE"
    else
        echo "Lock file removed."
    fi
fi

echo "Done."
