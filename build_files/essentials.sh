#!/bin/bash

set -ouex pipefail

# ---------------------------------------------------------------------------
# Package groups (arrays). Kept separated/commented for readability;
# flattened into ONE dnf5 transaction below.
# ---------------------------------------------------------------------------

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
  ghostty-kio
  ghostty-neovim
  ghostty-terminfo
  ghostty-bat-syntax
  ghostty-zsh-completion
)

USER_APPLICATIONS=(
  sushi
  flatseal
  resources
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
  qt5ct
  qt6ct
  nwg-look
  cliphist
  papirus-icon-theme
  breeze-cursor-theme
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