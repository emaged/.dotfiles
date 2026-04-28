#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Neovim via mise..."

sudo apt update
sudo apt install -y \
    btm \
    curl \
    git \
    lazygit \
    ruby-full \
    luarocks \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-pynvim \
    unzip \
    xz-utils

# Install mise if missing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/mise.sh"
ensure_mise

echo "==> Installing Neovim nightly..."
mise use -g neovim@nightly

echo "==> Installing Neovim Ruby provider..."
if ! gem list -i neovim >/dev/null 2>&1; then
    sudo gem install neovim
else
    echo "neovim Ruby gem already installed."
fi

echo "==> Neovim setup complete."
nvim --version | head -n 1
