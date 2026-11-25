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

NORIX_BASE=(
  jq
  niri
  grim
  slurp
  satty
  mangowm
  wlsunset
  libsecret
  wl-clipboard
  # Fedora 45 default Secret Service (replaces gnome-keyring). greetd's
  # PAM file already carries pam_oo7.so lines, so installing the module is
  # enough to unlock the login keyring.
  oo7-daemon
  oo7-portal
  pam_oo7
  brightnessctl
  adw-gtk3-theme
)

GHOSTTY_TERMINAL=(
  ghostty
)

USER_APPLICATIONS=(
  gcr
  bazaar
  seahorse
  nautilus
  helium-drm
  file-roller
  nautilus-python
  glycin-gtk4-libs
  ffmpegthumbnailer
  glycin-thumbnailer
  gnome-disk-utility
)

NOCTALIA_SHELL=(
  wtype
  greetd
  ddcutil
  cliphist
  noctalia
  noctalia-greeter
  evolution-data-server
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf5 transaction. Order in the array doesn't matter to dnf5's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${XDG_BASE[@]}"
  "${NORIX_BASE[@]}"
  "${GHOSTTY_TERMINAL[@]}"
  "${USER_APPLICATIONS[@]}"
  "${IME_INTERNATIONAL_INPUT[@]}"
  "${NOCTALIA_SHELL[@]}"
)

dnf5 install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"