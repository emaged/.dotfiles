#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing starship..."

if command -v starship &>/dev/null; then
  echo "starship already installed"
  exit 0
fi

curl -sS https://starship.rs/install.sh | sh -s -- -y

echo "starship installation complete."
