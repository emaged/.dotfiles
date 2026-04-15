#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing development tools..."

sudo pacman -S --needed --noconfirm \
  bat \
  bottom \
  cmake \
  cpio \
  git-delta \
  gdu \
  glab \
  imagemagick \
  inotify-tools \
  lua51 \
  meson \
  mkcert \
  ninja \
  pkgfile \
  tectonic \
  udiskie \
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
  yay -S --needed --noconfirm \
  jetbrains-toolbox \
  java-openjfx \
  java-openjfx-doc \
  java-openjfx-src
else
  echo "==> yay not found, skipping AUR packages."
fi

echo "==> Ensuring pkgfile database is initialized..."
if ! pkgfile -l bash &>/dev/null; then
  sudo pkgfile --update
fi

echo "==> Enabling pkgfile auto-update timer..."
sudo systemctl enable --now pkgfile-update.timer

echo "Development tools installed."
