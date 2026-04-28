#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing OpenCode..."

if ! command -v curl >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y curl
fi

curl -fsSL https://opencode.ai/install | bash

echo "✅ OpenCode installation complete."
