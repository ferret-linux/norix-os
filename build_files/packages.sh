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

SDDM_LOGIN_MANAGER=(
  sddm
  weston
  qt6-qtsvg
  qt6-qtmultimedia
  qt6-qtdeclarative
  sddm-wayland-generic
  qt6-qtquickcontrols2
)

GHOSTTY_TERMINAL=(
  ghostty
  ghostty-kio
  ghostty-neovim
  ghostty-nautilus
  ghostty-terminfo
  ghostty-bat-syntax
  ghostty-zsh-completion
  ghostty-shell-integration
)

USER_APPLICATIONS=(
  sushi
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
  system-config-printer
)

IME_INTERNATIONAL_INPUT=(
  fcitx5
  fcitx5-gtk
  fcitx5-qt6
  fcitx5-rime
  fcitx5-mozc
  fcitx5-m17n
  fcitx5-hangul
  fcitx5-unikey
  fcitx5-chewing
  fcitx5-libthai
  fcitx5-configtool
  fcitx5-table-extra
  fcitx5-chinese-addons
)

NOCTALIA_SHELL=(
  wtype
  qt5ct
  qt6ct
  ddcutil
  nwg-look
  cliphist
  noctalia
  papirus-icon-theme
  breeze-cursor-theme
  evolution-data-server
  papirus-icon-theme-dark
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf5 transaction. Order in the array doesn't matter to dnf5's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${XDG_BASE[@]}"
  "${NIRI_BASE[@]}"
  "${SDDM_LOGIN_MANAGER[@]}"
  "${GHOSTTY_TERMINAL[@]}"
  "${USER_APPLICATIONS[@]}"
  "${IME_INTERNATIONAL_INPUT[@]}"
  "${NOCTALIA_SHELL[@]}"
)

dnf5 install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"