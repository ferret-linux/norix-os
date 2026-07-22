#!/bin/bash

set -ouex pipefail

# ---------------------------------------------------------------------------
# Package groups (arrays). Kept separated/commented for readability;
# flattened into ONE dnf5 transaction below.
# ---------------------------------------------------------------------------

GAME_LAUNCHERS=(
  steam
  steam-devices
  retroarch
  protonplus
  input-remapper
  heroic-games-launcher
)

LUTRIS_WINE=(
  lutris
  wine
  winetricks
)

BOTTLES_RUNTIME=(
  bottles
)

PERFORMANCE_OVERLAY=(
  mangohud
  goverlay
  gamemode
  gamescope
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf5 transaction. Order in the array doesn't matter to dnf5's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${GAME_LAUNCHERS[@]}"
  "${LUTRIS_WINE[@]}"
  "${BOTTLES_RUNTIME[@]}"
  "${PERFORMANCE_OVERLAY[@]}"
)

dnf5 install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"