#!/bin/bash

set -ouex pipefail

# ---------------------------------------------------------------------------
# Package groups (arrays). Kept separated/commented for readability;
# flattened into ONE dnf5 transaction below.
# ---------------------------------------------------------------------------

XDG_BASE=(
  xdg-utils
  xdg-user-dirs
  xdg-terminal-exec
  xdg-user-dirs-gtk
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  xdg-desktop-portal-gnome
)

NIRI_BASE=(
  niri
  wlsunset
  libsecret
  wl-clipboard
  gnome-keyring
  brightnessctl
  adw-gtk3-theme
  gnome-keyring-pam
)

GHOSTTY_TERMINAL=(
  ghostty
  ghostty-nautilus
  ghostty-shell-integration
)

USER_APPLICATIONS=(
  bazaar
  seahorse
  nautilus
  helium-drm
  file-roller
  input-remapper
  nautilus-python
  glycin-gtk4-libs
  ffmpegthumbnailer
  glycin-thumbnailer
  gnome-disk-utility
)

NOCTALIA_SHELL=(
  wtype
  ddcutil
  cliphist
  noctalia
  evolution-data-server
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf5 transaction. Order in the array doesn't matter to dnf5's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${XDG_BASE[@]}"
  "${NIRI_BASE[@]}"
  "${GHOSTTY_TERMINAL[@]}"
  "${USER_APPLICATIONS[@]}"
  "${IME_INTERNATIONAL_INPUT[@]}"
  "${NOCTALIA_SHELL[@]}"
)

dnf5 install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"