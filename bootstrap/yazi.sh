#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Yazi and dependencies..."

packages=(
  yazi
  ffmpeg
  7zip
  jq
  poppler
  fd
  ripgrep
  fzf
  zoxide
  resvg
  imagemagick
)

sudo pacman -S --needed --noconfirm "${packages[@]}"

echo "Yazi installation complete."
