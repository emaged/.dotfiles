#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing cargo packages..."

if ! command -v cargo &>/dev/null; then
  echo "cargo not found. Install Rust first or run dev-tools.sh."
  exit 0
fi

crates=(
  ast-grep
  cargo-update
  du-dust
  neovide
  selene
  trashy
  tree-sitter-cli
)

for crate in "${crates[@]}"; do
  if cargo install --list | grep -q "^${crate} "; then
    echo "$crate already installed"
  else
    echo "Installing $crate..."
    cargo install "$crate"
  fi
done

echo "Cargo packages installation complete."
