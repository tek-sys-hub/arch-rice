#!/usr/bin/env bash
# Restore live wallpaper if configured in state
STATE_FILE="$HOME/.cache/cherry/state.json"
[ ! -f "$STATE_FILE" ] && STATE_FILE="$HOME/.cache/nisfere/state.json"

if [ -f "$STATE_FILE" ]; then
    WP=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('wallpaper', ''))" 2>/dev/null)
    if [[ "$WP" =~ \.(mp4|webm|mkv|mov|avi)$ ]] && [ -f "$WP" ]; then
        pkill -9 -x mpvpaper 2>/dev/null
        mpvpaper -p -o "no-audio loop --no-config --hwdec=auto" '*' "$WP" >/dev/null 2>&1 &
    fi
fi
