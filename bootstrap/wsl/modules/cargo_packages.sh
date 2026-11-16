#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
sudo apt-get install -y build-essential pkg-config libssl-dev clang libclang-dev cmake
if ! have cargo && ! have rustup; then
  run_installer https://sh.rustup.rs sh -y --no-modify-path --default-toolchain stable
fi
have cargo || die 'Cargo is unavailable after installing Rust.'
install_cargo_packages
