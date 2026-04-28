#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing cargo native build dependencies..."
sudo apt update
sudo apt install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    libfreetype6-dev \
    libfontconfig1-dev \
    clang \
    libclang-dev

echo "==> Installing cargo packages..."

# Ensure cargo exists
if ! command -v cargo &>/dev/null; then
    echo "cargo not found."

    # Install rustup if missing
    if ! command -v rustup &>/dev/null; then
        echo "==> Installing rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

        # Load cargo environment
        source "$HOME/.cargo/env"
    fi
fi

# If cargo still missing, abort
if ! command -v cargo &>/dev/null; then
    echo "Rust installation failed."
    exit 1
fi

# Update Rust if rustup exists
if command -v rustup &>/dev/null; then
    echo "==> Updating Rust toolchain..."
    rustup update stable
    rustup default stable
else
    echo "rustup unavailable; skipping Rust update."
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
        cargo install "$crate" --locked
    fi
done

echo "Cargo packages installation complete."
