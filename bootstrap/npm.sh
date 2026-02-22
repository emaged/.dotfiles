#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing global npm packages..."

if ! command -v npm &>/dev/null; then
  echo "npm not found. Make sure mise has installed node."
  exit 1
fi

packages=(
  "@openai/codex"
  browser-sync
  eslint_d
  eslint-config-prettier
  eslint
  htmlhint
  http-server
  live-server
  mcp-hub
  @mermaid-js/mermaid-cli
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
