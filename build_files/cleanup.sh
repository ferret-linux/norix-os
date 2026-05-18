#!/bin/bash

set -ouex pipefail

### DNF Cleanup
dnf config-manager setopt ferret-pkgs.enabled=0
rm -f /etc/yum.repos.d/ferret-pkgs.repo
dnf5 autoremove -y
dnf5 clean all
dnf5 clean packages

### OSTree/bootc dir cleanup
rm -rf /usr/etc
rm -rf /boot && mkdir -p /boot
find /var/* -maxdepth 0 -type d ! -name cache ! -name log -exec rm -rf {} \;
find /var/cache/* -maxdepth 0 -type d ! -name libdnf5 -exec rm -rf {} \;