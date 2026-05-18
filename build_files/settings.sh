#!/bin/bash

set -ouex pipefail

# Remove useless desktop entries
rm -f /usr/share/applications/btop.desktop
rm -f /usr/share/applications/qt6ct.desktop
rm -f /usr/share/applications/qt5ct.desktop
rm -f /usr/share/applications/kbd-layout-viewer5.desktop
rm -f /usr/share/applications/nvim.desktop
rm -f /usr/share/applications/nwg-look.desktop
# Fix weston dir permissions for sddm
chmod go+rx /etc/xdg
chmod go+rx /etc/xdg/weston
chmod go+r /etc/xdg/weston/weston.ini
# Disable XDG desktop portal 'gtk'
rm -rf /usr/share/xdg-desktop-portal/portals/gtk.portal
rm -rf /usr/share/dbus-1/services/org.freedesktop.impl.portal.desktop.gtk.service
rm -rf /usr/lib/systemd/user/xdg-desktop-portal-gtk.service
rm -rf /usr/share/applications/xdg-desktop-portal-gtk.desktop
# Enable SDDM login manager on boot
systemctl enable sddm.service