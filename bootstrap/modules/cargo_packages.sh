#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing cargo packages..."

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
