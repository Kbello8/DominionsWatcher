#!/bin/bash
# macOS setup: creates a clickable .command file that acts like a shortcut.
# You can drag the generated file to your Dock for quick access.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHORTCUT="$SCRIPT_DIR/Dominions6.command"

cat > "$SHORTCUT" << EOF
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
"$SCRIPT_DIR/dom6_launch.sh"
EOF

chmod +x "$SHORTCUT"

if [ -f "$SHORTCUT" ]; then
    echo "Shortcut created: $SHORTCUT"
    echo "Drag it to your Dock for quick access."
else
    echo "ERROR: Shortcut creation failed."
fi
