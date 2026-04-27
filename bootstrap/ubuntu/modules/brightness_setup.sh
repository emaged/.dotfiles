#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing ddcutil..."

sudo apt install -y ddcutil

echo "==> Ensuring i2c-dev module is loaded..."

if ! lsmod | grep -q i2c_dev; then
  sudo modprobe i2c-dev
fi

echo "i2c-dev" | sudo tee /etc/modules-load.d/i2c-dev.conf >/dev/null

echo "==> Adding user to i2c group..."

sudo groupadd -f i2c

if ! groups "$USER" | grep -q '\bi2c\b'; then
  sudo usermod -aG i2c "$USER"
  echo "User added to i2c group."
  echo "⚠️ You must log out and log back in for this to take effect."
else
  echo "User already in i2c group."
fi

echo "==> Verifying DDC detection..."

if ddcutil detect >/dev/null 2>&1; then
  echo "DDC-compatible displays detected."
else
  echo "⚠️ No DDC displays detected."
  echo "If using NVIDIA, you may need additional configuration."
fi

echo "Brightness setup complete."
