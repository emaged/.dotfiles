#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGINS_DIR="$HOME/.config/tmux/plugins"

if ! command -v omarchy &>/dev/null; then
  echo "Omarchy is required to set up tmux theme synchronization." >&2
  exit 1
fi

echo "==> Installing tmux..."
sudo pacman -S --needed --noconfirm tmux

echo "==> Setting up tmux environment..."

# Install / update TPM
TPM_DIR="$PLUGINS_DIR/tpm"
mkdir -p "$PLUGINS_DIR"

if [[ -d "$TPM_DIR/.git" ]]; then
  echo "Updating TPM..."
  git -C "$TPM_DIR" pull --ff-only
else
  echo "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

# Install PowerKit, matching the plugin declared in the dotfiles tmux.conf.
POWERKIT_DIR="$PLUGINS_DIR/tmux-powerkit"

if [[ -d "$POWERKIT_DIR/.git" ]]; then
  echo "PowerKit already installed."
else
  echo "Installing PowerKit tmux theme..."
  git clone https://github.com/fabioluciano/tmux-powerkit.git "$POWERKIT_DIR"
fi

echo "==> Setting up Omarchy theme synchronization..."
THEME_HELPER="$ROOT_DIR/files/omarchy-tmux-theme-set"
install -Dm755 "$THEME_HELPER" "$HOME/.local/bin/omarchy-tmux-theme-set"

# Older installations already call the helper from the flat theme-set hook.
# Keep that hook and avoid adding a second invocation on those systems.
LEGACY_HOOK="$HOME/.config/omarchy/hooks/theme-set"
if [[ -f "$LEGACY_HOOK" ]] && grep -Fxq "$HOME/.local/bin/omarchy-tmux-theme-set" "$LEGACY_HOOK"; then
  echo "Existing Omarchy theme hook already runs the tmux helper."
else
  omarchy hook install theme-set "$THEME_HELPER"
fi

"$HOME/.local/bin/omarchy-tmux-theme-set" --no-reload

echo "tmux setup complete."
