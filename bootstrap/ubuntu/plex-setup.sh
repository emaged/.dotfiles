#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Plex Media Server prerequisites..."
sudo apt update
sudo apt install -y curl gnupg

KEYRING="/etc/apt/keyrings/plexmediaserver.v2.gpg"
SOURCE_FILE="/etc/apt/sources.list.d/plex.list"
SOURCE_LINE="deb [signed-by=$KEYRING] https://repo.plex.tv/deb/ public main"

echo "==> Configuring Plex apt repository..."
sudo mkdir -p /etc/apt/keyrings

if [[ ! -f "$KEYRING" ]]; then
  curl -L https://downloads.plex.tv/plex-keys/PlexSign.v2.key \
    | sudo gpg --yes --dearmor -o "$KEYRING"
else
  echo "Plex keyring already present."
fi

if [[ ! -f "$SOURCE_FILE" ]] || ! grep -Fq "$SOURCE_LINE" "$SOURCE_FILE"; then
  echo "$SOURCE_LINE" | sudo tee "$SOURCE_FILE" >/dev/null
else
  echo "Plex repository already configured."
fi

echo "==> Installing Plex Media Server..."
sudo apt update
sudo apt install -y plexmediaserver

echo "==> Enabling Plex service..."
sudo systemctl enable plexmediaserver.service

echo "==> Starting Plex service..."
sudo systemctl start plexmediaserver.service

echo "==> Ensuring plex user exists..."
if ! id plex &>/dev/null; then
  echo "Plex user not found. Something may have gone wrong."
  exit 1
fi

echo
echo "✅ Plex Media Server is installed and running."
echo "👉 Open: http://localhost:32400/web"
echo
echo "If accessing remotely on LAN:"
echo "👉 http://<your-server-ip>:32400/web"
