#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing cargo native build dependencies..."
sudo apt update
sudo apt install -y \
    build-essential \
    ca-certificates \
    curl \
    pkg-config \
    libssl-dev \
    libfreetype6-dev \
    libfontconfig1-dev \
    clang \
    libclang-dev

echo "==> Installing cargo packages..."

if ! command -v rustup &>/dev/null; then
    echo "==> Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs |
        sh -s -- -y
fi

if [[ -r "$HOME/.cargo/env" ]]; then
    source "$HOME/.cargo/env"
fi

if ! command -v cargo &>/dev/null; then
    echo "Rust installation failed."
    exit 1
fi

echo "==> Updating Rust toolchain..."
rustup update stable
rustup default stable

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
