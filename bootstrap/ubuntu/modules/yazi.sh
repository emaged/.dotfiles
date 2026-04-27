#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Yazi and dependencies..."

sudo apt install -y \
  ffmpeg \
  7zip \
  file \
  fd-find \
  fzf \
  imagemagick \
  jq \
  poppler-utils \
  ripgrep \
  wl-clipboard \
  zoxide

if apt-cache show yazi >/dev/null 2>&1; then
  sudo apt install -y yazi
  echo "Yazi installed via apt."
elif command -v cargo &>/dev/null; then
  echo "==> yazi package not available via apt, installing with cargo..."
  cargo install --force yazi-build
  echo "Yazi installed via cargo fallback."
else
  echo "Yazi package is not available via apt and cargo is not installed."
  echo "Skipping Yazi binary installation."
fi

echo "Yazi installation complete."
