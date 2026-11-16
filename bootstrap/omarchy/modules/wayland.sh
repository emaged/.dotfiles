#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Wayland utilities..."

omarchy pkg add wl-clip-persist

echo "Wayland utilities installed."
