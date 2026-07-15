# ==============================================================
#  NorixOS container image build
#  Base: ${BASE_IMAGE}
# ==============================================================

ARG BASE_IMAGE

# ── Build context ─────────────────────────────────────────────
# Allow build scripts and system_files overlays to be referenced
# without being copied into the final image directly.
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files

# ── Base image ───────────────────────────────────────────────
FROM ${BASE_IMAGE}

ARG IMAGE_NAME
ARG IMAGE_VENDOR="ferret-linux"
ARG IMAGE_TAG="latest"
ENV IMAGE_NAME=${IMAGE_NAME}

# ── OS release metadata ─────────────────────────────────────────
RUN sed -i 's/^NAME=.*/NAME="NorixOS"/' /usr/lib/os-release && \
    sed -i 's/^PRETTY_NAME=.*/PRETTY_NAME="NorixOS Linux"/' /usr/lib/os-release

# ── Repositories ─────────────────────────────────────────────
RUN dnf config-manager addrepo --from-repofile=https://ferretlinux.org/repo/ferret-pkgs.repo && \
    dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo && \
    dnf config-manager setopt ferret-pkgs.enabled=1 && \
    dnf config-manager setopt fedora-multimedia.enabled=1 && \
    dnf config-manager setopt fedora-multimedia.priority=80 && \
    dnf config-manager setopt ferret-pkgs.priority=90 && \
    dnf --refresh makecache && \
    dnf upgrade --setopt=install_weak_deps=false

# Make /opt a real directory before package install (some packages
# expect to write here directly).
RUN rm -rf /opt && mkdir -p /opt

# ── Package installation ─────────────────────────────────────
# system_files/ and build_files/ are split per flavor (mx, essentials,
# dx, gx, vx), same convention as mink-os/RubinOS. Layer the matching
# scripts using the IMAGE_NAME suffix:
#   mx          -> ALL variants (core desktop)
#   essentials  -> all variants EXCEPT *-mx / *-mx-nvidia
#   dx          -> *-dx / *-dx-nvidia / *-vx / *-vx-nvidia (vx = dx + vx)
#   gx          -> *-gx / *-gx-nvidia only
#   vx          -> *-vx / *-vx-nvidia only (layered on top of dx)
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/mx-setup.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-mx|*-mx-nvidia) : ;; \
        *) bash /ctx/essentials.sh ;; \
    esac

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-dx|*-dx-*|*-vx|*-vx-*) bash /ctx/dx-setup.sh ;; \
        *) : ;; \
    esac

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-gx|*-gx-*) bash /ctx/gx-setup.sh ;; \
        *) : ;; \
    esac

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    case "${IMAGE_NAME}" in \
        *-vx|*-vx-*) bash /ctx/vx-setup.sh ;; \
        *) : ;; \
    esac

# ── Package version lock ─────────────────────────────────────
# Lock all installed packages to their current versions/releases,
# making rebase/upgrade behavior deterministic for this image.
# (dnf5 writes this to /etc/dnf/versionlock.toml — part of the
# committed OS tree, not /var — so it persists correctly.)
RUN dnf versionlock add $(rpm -qa --qf '%{NAME}\n')

# ── Enable services ───────────────────────────────────────────
RUN systemctl enable sddm.service || true

# ── Disable GTK desktop portal (old) ──────────────────────────
RUN rm -rf /usr/share/xdg-desktop-portal/portals/gtk.portal && \
    rm -rf /usr/share/dbus-1/services/org.freedesktop.impl.portal.desktop.gtk.service && \
    rm -rf /usr/lib/systemd/user/xdg-desktop-portal-gtk.service && \
    rm -rf /usr/share/applications/xdg-desktop-portal-gtk.desktop

# ── System files ─────────────────────────────────────────────
# Same per-variant overlay logic as the package-install steps above.
# `cp -a src/. /` merges directory contents onto root without
# clobbering the whole tree (unlike a bare `COPY system_files/ /`,
# which would dump literal /mx, /essentials, /dx, /gx, /vx folders
# at the filesystem root instead of overlaying their etc/usr trees).
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    cp -a /ctx/system_files/mx/. / && \
    case "${IMAGE_NAME}" in \
        *-mx|*-mx-nvidia) : ;; \
        *) cp -a /ctx/system_files/essentials/. / ;; \
    esac && \
    case "${IMAGE_NAME}" in \
        *-dx|*-dx-*|*-vx|*-vx-*) cp -a /ctx/system_files/dx/. / ;; \
        *) : ;; \
    esac && \
    case "${IMAGE_NAME}" in \
        *-gx|*-gx-*) cp -a /ctx/system_files/gx/. / ;; \
        *) : ;; \
    esac && \
    case "${IMAGE_NAME}" in \
        *-vx|*-vx-*) cp -a /ctx/system_files/vx/. / ;; \
        *) : ;; \
    esac

# ── Fix Weston Config (SDDM) ──────────────────────────────────
RUN chmod go+rx /etc/xdg && \
    chmod go+rx /etc/xdg/weston && \
    chmod go+r /etc/xdg/weston/weston.ini

# ── /opt → immutable tree migration ───────────────────────────
# Move /opt contents into the immutable /usr tree, create
# tmpfiles.d entries to symlink them back at runtime, then replace
# /opt with a symlink into /var so it stays writable.
RUN mkdir -p /usr/lib/opt && \
    mv /opt/* /usr/lib/opt/ 2>/dev/null || true && \
    for dir in /usr/lib/opt/*/; do \
        opt=$(basename "$dir"); \
        echo "L+?  \"/opt/${opt}\"  -  -  -  -  /usr/lib/opt/${opt}" > /usr/lib/tmpfiles.d/99-optfix-${opt}.conf; \
    done && \
    rm -rf /opt && ln -s /var/opt /opt && \
    mkdir -p /var/roothome && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp

# ── Repository cleanup ───────────────────────────────────────
# Remove build-only repos/coprs so they don't ship in the final image.
RUN dnf config-manager setopt ferret-pkgs.enabled=0 && \
    dnf config-manager setopt fedora-multimedia.enabled=0 && \
    rm -f /etc/yum.repos.d/ferret-pkgs.repo && \
    rm -f /etc/yum.repos.d/fedora-multimedia.repo && \
    dnf5 autoremove -y && \
    dnf5 clean all && \
    dnf5 clean packages

# ── Remove unwanted desktop entries ───────────────────────────
RUN rm -f /usr/share/applications/btop.desktop && \
    rm -f /usr/share/applications/qt6ct.desktop && \
    rm -f /usr/share/applications/qt5ct.desktop && \
    rm -f /usr/share/applications/kbd-layout-viewer5.desktop && \
    rm -f /usr/share/applications/nvim.desktop && \
    rm -f /usr/share/applications/nwg-look.desktop

# ── Installed package count ──────────────────────────────────
RUN echo "📦 Total installed packages: $(rpm -qa | wc -l)"

# ── InitRAMFS build ──────────────────────────────────────────
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    bash /ctx/initramfs.sh

# ── Image Cleanup (for Bootc compatibility) ──────────────────
RUN find /var/* -maxdepth 0 -type d ! -name cache ! -name log -exec rm -rf {} \; && \
    find /var/cache/* -maxdepth 0 -type d ! -name libdnf5 -exec rm -rf {} \; && \
    rm -rf /boot && mkdir -p /boot && \
    rm -rf /usr/etc

# ── Linting ──────────────────────────────────────────────────
# Verify final image and contents are correct.
RUN bootc container lint