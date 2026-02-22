#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up systemd SSH agent..."

# Enable ssh-agent user service
systemctl --user enable ssh-agent.service
systemctl --user start ssh-agent.service

echo "==> Ensuring SSH_AUTH_SOCK is exported in .zshrc..."

if ! grep -q "SSH_AUTH_SOCK" "$HOME/.zshrc"; then
  echo 'export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"' >> "$HOME/.zshrc"
  echo "Added SSH_AUTH_SOCK export to .zshrc"
else
  echo "SSH_AUTH_SOCK already configured."
fi

echo
echo "Now run:"
echo "  ssh-add ~/.ssh/id_ed25519"
echo
echo "Enter your passphrase once. It will persist for the session."
