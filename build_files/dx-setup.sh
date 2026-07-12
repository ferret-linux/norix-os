#!/bin/bash

set -ouex pipefail

# ---------------------------------------------------------------------------
# Package groups (arrays). Kept separated/commented for readability;
# flattened into ONE dnf5 transaction below.
# ---------------------------------------------------------------------------

EDITORS_IDE=(
  code
)

CONTAINER_TOOLING=(
  podman
  pods
)

VERSION_CONTROL=(
  git
  git-lfs
  gh
)

ANDROID_TESTING=(
  waydroid
)

# ---------------------------------------------------------------------------
# Flatten everything into one package list and install in a single
# dnf5 transaction. Order in the array doesn't matter to dnf5's resolver.
# ---------------------------------------------------------------------------
ALL_PACKAGES=(
  "${EDITORS_IDE[@]}"
  "${CONTAINER_TOOLING[@]}"
  "${VERSION_CONTROL[@]}"
  "${ANDROID_TESTING[@]}"
)

dnf5 install -y --setopt=install_weak_deps=False "${ALL_PACKAGES[@]}"