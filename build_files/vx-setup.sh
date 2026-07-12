#!/bin/bash

set -ouex pipefail

# ---------------------------------------------------------------------------
# Package groups (arrays). Kept separated/commented for readability;
# flattened into ONE dnf5 transaction below.
# ---------------------------------------------------------------------------


VM_MANAGEMENT_UI=(
  virt-manager
  virt-viewer
  gnome-boxes
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf5 transaction. Order in the array doesn't matter to dnf5's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${VM_MANAGEMENT_UI[@]}"
)

dnf5 install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"