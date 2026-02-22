#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing tmux..."

if ! pacman -Qi tmux &>/dev/null; then
  sudo pacman -S --needed --noconfirm tmux
else
  echo "tmux already installed"
fi

echo "tmux setup complete."
