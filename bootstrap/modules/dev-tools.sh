#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing development tools..."

sudo pacman -S --needed --noconfirm \
  bat \
  bottom \
  cmake \
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
  wget 

echo "==> Ensuring pkgfile database is initialized..."
if ! pkgfile -l bash &>/dev/null; then
  sudo pkgfile --update
fi

echo "==> Enabling pkgfile auto-update timer..."
sudo systemctl enable --now pkgfile-update.timer

echo "Development tools installed."
