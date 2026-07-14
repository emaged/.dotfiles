#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Firefox..."

sudo pacman -S --needed --noconfirm firefox
sudo pacman -S --needed --noconfirm firefox-developer-edition
sudo pacman -S --needed --noconfirm geoclue

echo "==> Setting Firefox as default browser..."

# Set default browser via xdg
xdg-settings set default-web-browser firefox.desktop

# Also ensure common URL handlers are mapped
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https
xdg-mime default firefox.desktop text/html

echo "Firefox installation and default configuration complete."
