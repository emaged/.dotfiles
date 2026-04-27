#!/usr/bin/env bash

set -euo pipefail

echo "==> Installing Plex Media Server..."
if ! pacman -Qs "^plex-media-server$" > /dev/null; then
    sudo pacman -S --needed --noconfirm plex-media-server
else
    echo "Plex Media Server already installed."
fi

echo "==> Enabling Plex service..."
sudo systemctl enable plexmediaserver.service

echo "==> Starting Plex service..."
sudo systemctl start plexmediaserver.service

echo "==> Ensuring plex user exists..."
if ! id plex &>/dev/null; then
    echo "Plex user not found. Something may have gone wrong."
    exit 1
fi

echo ""
echo "✅ Plex Media Server is installed and running."
echo "👉 Open: http://localhost:32400/web"
echo ""
echo "If accessing remotely on LAN:"
echo "👉 http://<your-server-ip>:32400/web"
