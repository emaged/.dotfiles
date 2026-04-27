#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing zsh..."

sudo apt install -y zsh

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
