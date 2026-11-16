#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
sudo apt-get install -y build-essential pkg-config libssl-dev libfreetype6-dev \
  libfontconfig1-dev clang libclang-dev cmake ninja-build libasound2-dev libexpat1-dev \
  libxcb-composite0-dev libbz2-dev libsndio-dev libglut-dev libxmu-dev libxi-dev libxcursor-dev
if [[ $(dpkg --print-architecture) == amd64 ]]; then
  sudo apt-get install -y gcc-multilib g++-multilib
fi
if ! have cargo && ! have rustup; then
  run_installer https://sh.rustup.rs sh -y --no-modify-path --default-toolchain stable
fi
have cargo || die 'Cargo is unavailable after installing Rust.'
install_cargo_packages
