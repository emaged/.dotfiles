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

installed_crates="$(cargo install --list)"

for crate in "${crates[@]}"; do
  if grep -q "^${crate} " <<<"$installed_crates"; then
    echo "$crate already installed"
  else
    echo "Installing $crate..."
    cargo install "$crate" --locked
  fi
done

echo "Cargo packages installation complete."
