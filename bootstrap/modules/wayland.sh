#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Wayland utilities..."

sudo pacman -S --needed --noconfirm wl-clip-persist

echo "Wayland utilities installed."
