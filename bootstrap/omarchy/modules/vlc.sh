#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing VLC..."

sudo pacman -S --needed --noconfirm vlc
sudo pacman -S --needed --noconfirm vlc-plugins-all

echo "VLC installed."
