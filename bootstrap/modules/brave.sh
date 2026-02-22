#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Brave (AUR: brave-bin)..."

if ! command -v yay >/dev/null 2>&1; then
  echo "ERROR: yay is not installed. Install yay first (or switch this script to paru)."
  exit 1
fi

# -S installs without partial upgrade issues (avoid -Sy)
yay -S --needed --noconfirm brave-bin

echo "Brave installed."
