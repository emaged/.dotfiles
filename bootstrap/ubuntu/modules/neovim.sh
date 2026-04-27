#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Neovim..."

sudo apt install -y neovim ruby-full luarocks

echo "==> Installing Neovim Ruby provider..."

if ! command -v gem >/dev/null 2>&1; then
  echo "Ruby not found. Install ruby-full first."
  exit 1
fi

if gem list -i neovim >/dev/null 2>&1; then
  echo "neovim Ruby gem already installed."
else
  sudo gem install neovim
fi

echo "Neovim setup complete."
