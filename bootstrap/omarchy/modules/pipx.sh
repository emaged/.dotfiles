#!/usr/bin/env bash
set -euo pipefail

echo "==> Ensuring pipx is installed..."

if ! command -v pipx &>/dev/null; then
  echo "Installing pipx via pacman..."
  sudo pacman -S --needed --noconfirm python-pipx
else
  echo "pipx already installed"
fi

# Ensure pipx binary path exists in PATH
pipx ensurepath >/dev/null 2>&1 || true

echo "==> Installing / upgrading pipx packages..."

packages=(
  black
  djlint
  hererocks
  ipython
  poetry
  pynvim
  pytest
  ruff
)

for pkg in "${packages[@]}"; do
  if pipx list | grep -q "$pkg"; then
    echo "Upgrading $pkg..."
    pipx upgrade "$pkg"
  else
    echo "Installing $pkg..."
    pipx install "$pkg"
  fi
done

echo "pipx packages installed/upgraded to latest."
