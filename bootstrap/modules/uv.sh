#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing uv..."

if command -v uv &>/dev/null; then
  echo "uv already installed"
  exit 0
fi

curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
sh /tmp/uv-install.sh
rm /tmp/uv-install.sh

echo "uv installation complete."
