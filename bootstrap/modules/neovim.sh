#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Neovim (nightly via neovim-git)..."

# Ensure yay exists
if ! command -v yay >/dev/null 2>&1; then
  echo "ERROR: yay is not installed. Install yay first."
  exit 1
fi

# Install neovim-git (nightly)
yay -S --needed --noconfirm neovim-git

echo "==> Installing Neovim Ruby provider..."

if ! command -v gem >/dev/null 2>&1; then
  echo "Ruby not found. Install ruby first."
  exit 1
fi

if gem list -i neovim >/dev/null 2>&1; then
  echo "neovim Ruby gem already installed."
else
  gem install neovim
fi

echo "Neovim setup complete."
