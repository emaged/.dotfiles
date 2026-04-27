#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing tmux..."
sudo pacman -S --needed --noconfirm tmux

echo "==> Setting up tmux environment..."

# Install / update TPM
TPM_DIR="$HOME/.tmux/plugins/tpm"

if [[ -d "$TPM_DIR/.git" ]]; then
  echo "Updating TPM..."
  git -C "$TPM_DIR" pull --ff-only
else
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Install / update Catppuccin (manual method)
CATPPUCCIN_DIR="$HOME/.config/tmux/plugins/catppuccin/tmux"

if [[ -d "$CATPPUCCIN_DIR/.git" ]]; then
  echo "Catppuccin already installed (version pinned)."
else
  echo "Installing Catppuccin tmux theme..."
  mkdir -p "$HOME/.config/tmux/plugins/catppuccin"
  git clone -b v2.1.3 https://github.com/catppuccin/tmux.git \
    "$CATPPUCCIN_DIR"
fi

echo "tmux setup complete."
