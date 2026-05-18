#!/bin/bash

set -ouex pipefail

# Base XDG packages
dnf5 install -y --setopt=install_weak_deps=False \
    xdg-utils \
    xdg-user-dirs \
    xdg-desktop-portal \
    xdg-desktop-portal-gtk \
    xdg-desktop-portal-gnome
# Base Niri packages
dnf5 install -y --setopt=install_weak_deps=False \
    niri \
    wlsunset \
    wl-clipboard \
    gnome-keyring \
    brightnessctl \
    adw-gtk3-theme \
    gnome-keyring-pam
# Sddm login manager
dnf5 install -y --setopt=install_weak_deps=False \
    sddm \
    weston \
    qt6-qtsvg \
    qt6-qtmultimedia \
    qt6-qtdeclarative \
    sddm-wayland-generic \
    qt6-qtquickcontrols2
# Ghostty Terminal emulator
dnf5 install -y --setopt=install_weak_deps=False \
    ghostty \
    ghostty-kio \
    ghostty-neovim \
    ghostty-nautilus \
    ghostty-terminfo \
    ghostty-bat-syntax \
    ghostty-zsh-completion \
    ghostty-shell-integration
# User applications
dnf5 install -y --setopt=install_weak_deps=False \
    seahorse \
    nautilus \
    helium-drm \
    file-roller \
    input-remapper \
    nautilus-python \
    glycin-gtk4-libs \
    ffmpegthumbnailer \
    glycin-thumbnailer \
    gnome-disk-utility \
    system-config-printer
# IME/International inputs
dnf5 install -y --setopt=install_weak_deps=False \
    fcitx5 \
    fcitx5-gtk \
    fcitx5-qt6 \
    fcitx5-rime \
    fcitx5-mozc \
    fcitx5-m17n \
    fcitx5-hangul \
    fcitx5-unikey \
    fcitx5-chewing \
    fcitx5-libthai \
    fcitx5-configtool \
    fcitx5-table-extra \
    fcitx5-chinese-addons
# Noctalia shell
dnf5 install -y --setopt=install_weak_deps=False \
    wtype \
    qt5ct \
    qt6ct \
    ddcutil \
    nwg-look \
    cliphist \
    noctalia-shell-v5 \
    papirus-icon-theme \
    breeze-cursor-theme \
    evolution-data-server \
    papirus-icon-theme-dark