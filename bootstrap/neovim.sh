#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Neovim Ruby provider..."

if ! command -v gem &>/dev/null; then
  echo "Ruby not found. Install ruby first."
  exit 1
fi

if gem list -i neovim >/dev/null 2>&1; then
  echo "neovim Ruby gem already installed."
else
  gem install neovim
fi

echo "Neovim Ruby provider installed."
