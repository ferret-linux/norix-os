#!/usr/bin/env bash
# ============================================================================
# Shared NorixOS screenshots (grim + slurp + satty + wl-copy)
#
#   usage: screenshot.sh <mode>
#   modes: fullscreen | region | window | clip
#
#   fullscreen : grim the whole screen                 -> satty -> save+copy
#   region     : slurp a region                        -> satty -> save+copy
#   window     : slurp -w pick a window                -> satty -> save+copy
#   clip       : slurp a region -> straight to clipboard (no file/satty)
#
# On save the image is also copied to the clipboard; cliphist's store daemon
# picks it up automatically.
# ============================================================================

set -euo pipefail

MODE=${1:-fullscreen}
TMP=""
OUT=""

cleanup() {
    [[ -n "${TMP}" && -f "${TMP}" ]] && rm -f "${TMP}"
}
trap cleanup EXIT

mkdir -p "${HOME}/Pictures/Screenshots"
OUT="${HOME}/Pictures/Screenshots/Screenshot-$(date +%Y-%m-%d-%H-%M-%S).png"

case "${MODE}" in
    clip)
        GEOM=$(slurp -d)
        [[ -z "${GEOM}" ]] && exit 1
        TMP=$(mktemp --suffix=.png)
        grim -g "${GEOM}" "${TMP}"
        wl-copy --type image/png < "${TMP}"
        exit 0
        ;;
    window)
        GEOM=$(slurp -w)
        [[ -z "${GEOM}" ]] && exit 1
        TMP=$(mktemp --suffix=.png)
        grim -g "${GEOM}" "${TMP}"
        ;;
    region)
        GEOM=$(slurp -d)
        [[ -z "${GEOM}" ]] && exit 1
        TMP=$(mktemp --suffix=.png)
        grim -g "${GEOM}" "${TMP}"
        ;;
    fullscreen)
        TMP=$(mktemp --suffix=.png)
        grim "${TMP}"
        ;;
    *)
        echo "screenshot.sh: unknown mode '${MODE}'" >&2
        exit 1
        ;;
esac

satty --filename "${TMP}" --output-filename "${OUT}" \
      --actions-on-enter save-to-file --early-exit

if [[ ! -f "${OUT}" ]]; then
    # User cancelled (Esc) — nothing saved, nothing copied.
    exit 1
fi

wl-copy --type image/png < "${OUT}"

if command -v notify-send >/dev/null 2>&1; then
    notify-send --app-name="norix-screenshot" \
        "Screenshot saved & copied" "${OUT}"
fi