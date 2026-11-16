#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing VLC..."

omarchy pkg add vlc
omarchy pkg add vlc-plugins-all

echo "VLC installed."
