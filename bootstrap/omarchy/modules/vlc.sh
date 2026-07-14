#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing VLC..."

sudo pacman -S --needed --noconfirm vlc

echo "VLC installed."
