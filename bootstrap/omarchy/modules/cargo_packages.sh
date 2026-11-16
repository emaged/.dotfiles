#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
omarchy pkg add base-devel clang cmake fontconfig freetype2 openssl
if ! have cargo && ! have rustup; then
  omarchy pkg add rust
fi
have cargo || die 'Cargo is unavailable; configure a Rust toolchain before continuing.'
install_cargo_packages
