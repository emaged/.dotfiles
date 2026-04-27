#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Brave..."

sudo apt install -y curl

KEYRING="/usr/share/keyrings/brave-browser-archive-keyring.gpg"
SOURCE_FILE="/etc/apt/sources.list.d/brave-browser-release.sources"

if [[ ! -f "$KEYRING" ]]; then
  sudo curl -fsSLo "$KEYRING" \
    https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
else
  echo "Brave keyring already present."
fi

if [[ ! -f "$SOURCE_FILE" ]]; then
  sudo curl -fsSLo "$SOURCE_FILE" \
    https://brave-browser-apt-release.s3.brave.com/brave-browser.sources
else
  echo "Brave apt source already present."
fi

sudo apt update
sudo apt install -y brave-browser

echo "Brave installed."
