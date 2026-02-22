#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Julia..."

if command -v julia &>/dev/null; then
  echo "Julia already installed."
  exit 0
fi

curl -fsSL https://install.julialang.org -o /tmp/julia-install.sh
sh /tmp/julia-install.sh -y
rm /tmp/julia-install.sh

echo "Julia installation complete."
