#!/bin/bash

set -ouex pipefail

### Cleanup
dnf config-manager setopt ferret-pkgs.enabled=0
rm -f /etc/yum.repos.d/ferret-pkgs.repo
dnf5 autoremove -y
dnf5 clean all
dnf5 clean packages