#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing zsh..."

if ! pacman -Qi zsh &>/dev/null; then
  sudo pacman -S --needed --noconfirm zsh
else
  echo "zsh already installed"
fi

echo "==> Ensuring zsh is in /etc/shells..."

if ! grep -qx "$(command -v zsh)" /etc/shells; then
  echo "$(command -v zsh)" | sudo tee -a /etc/shells >/dev/null
fi

echo "==> Setting zsh as default shell..."

if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
  echo "Default shell changed to zsh. Log out and back in."
else
  echo "zsh already default shell"
fi

echo "Done."
