#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing global npm packages..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/mise.sh"

ensure_mise

echo "==> Installing Node.js via mise..."
mise use -g node@latest

eval "$(mise activate bash)"
hash -r

if ! command -v node >/dev/null 2>&1; then
    echo "node not found after mise install."
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found after mise Node install."
    exit 1
fi

packages=(
    "@openai/codex"
    "@mermaid-js/mermaid-cli"
    "@github/copilot"
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
    name="$pkg"

    if npm list -g --depth=0 "$name" >/dev/null 2>&1; then
        echo "$pkg already installed"
    else
        echo "Installing $pkg..."
        npm install -g "$pkg"
    fi
done

echo "Global npm packages installation complete."
