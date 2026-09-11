#!/usr/bin/env bash

LOCK="/tmp/noctalia-sessionmenu-power.lock"
NOW=$(date +%s%3N) # milliseconds

# Laptop power buttons can emit the event twice in quick succession,
# and a plain check-then-write races between the two processes (both
# read the old timestamp, both toggle, panel flips open/closed).
# flock makes the debounce check atomic.
exec 9>"${LOCK}"
flock 9

LAST=0
if [[ -s "${LOCK}" ]]; then
    LAST=$(<"${LOCK}")
fi

# Ignore a second event within 500ms of the last one.
if (( NOW - LAST < 500 )); then
    exit 0
fi

echo "${NOW}" > "${LOCK}"

noctalia msg panel-toggle session

exec 9>&-