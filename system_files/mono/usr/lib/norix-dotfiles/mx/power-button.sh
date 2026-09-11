#!/usr/bin/env bash

LOCK="/tmp/noctalia-sessionmenu-power.lock"
NOW=$(date +%s%3N) # milliseconds

if [[ -f "$LOCK" ]]; then
    LAST=$(cat "$LOCK" 2>/dev/null || echo 0)
else
    LAST=0
fi

# Ignore if triggered again within 300ms
if (( NOW - LAST < 300 )); then
    exit 0
fi

echo "$NOW" > "$LOCK"
noctalia msg panel-toggle session