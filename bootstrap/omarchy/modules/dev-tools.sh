#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing development tools..."

omarchy pkg add \
    bat \
    bc \
    bottom \
    cmake \
    cpio \
    eza \
    git-delta \
    gdu \
    glab \
    imagemagick \
    inotify-tools \
    lua51 \
    maven \
    meson \
    mkcert \
    ninja \
    pkgfile \
    tectonic \
    udiskie \
    wev \
    wget \
    \
    jdk-openjdk \
    openjdk-doc \
    openjdk-src \
    \
    jdk21-openjdk \
    openjdk21-doc \
    openjdk21-src \
    \
    jdk17-openjdk \
    openjdk17-doc \
    openjdk17-src \
    \
    jdk11-openjdk \
    openjdk11-doc \
    openjdk11-src \
    \
    jdk8-openjdk \
    openjdk8-doc \
    openjdk8-src

if command -v yay &>/dev/null; then
    echo "==> Installing AUR packages..."
    omarchy pkg aur add \
        jetbrains-toolbox \
        mongodb-atlas-cli-bin \
        mongodb-tools-bin \
        mongosh-bin \
        postman-bin
    # java-openjfx \
    # java-openjfx-doc \
    # java-openjfx-src
else
    echo "ERROR: yay is required for the requested AUR packages." >&2
    exit 1
fi

echo "==> Ensuring pkgfile database is initialized..."
if ! pkgfile -l bash &>/dev/null; then
    sudo pkgfile --update
fi

echo "==> Enabling pkgfile auto-update timer..."
sudo systemctl enable --now pkgfile-update.timer

echo "Development tools installed."
