#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
if ! have starship; then
  mkdir -p "$HOME/.local/bin"
  run_installer https://starship.rs/install.sh sh --yes --bin-dir "$HOME/.local/bin"
fi
