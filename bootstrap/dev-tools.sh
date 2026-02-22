#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing development tools..."

sudo pacman -S --needed --noconfirm \
  bat \
  bottom \
  cmake \
  git-delta \
  glab \
  imagemagick \
  inotify-tools \
  meson \
  mkcert \
  ninja \
  udiskie

echo "Development tools installed."
