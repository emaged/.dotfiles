#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing global npm packages..."

if ! command -v npm &>/dev/null; then
  echo "npm not found. Install Node.js first."
  exit 1
fi

packages=(
  "@openai/codex"
  "@mermaid-js/mermaid-cli"
  browser-sync
  eslint
  eslint-config-prettier
  eslint_d
  htmlhint
  http-server
  live-server
  mcp-hub
  neovim
  prettier
)

for pkg in "${packages[@]}"; do
  if npm list -g --depth=0 | grep -q "$(basename "$pkg")@"; then
    echo "$pkg already installed"
  else
    echo "Installing $pkg..."
    npm install -g "$pkg"
  fi
done

echo "Global npm packages installation complete."
