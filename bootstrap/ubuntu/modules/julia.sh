#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
export PATH="$HOME/.juliaup/bin:$PATH"
if ! have juliaup; then
  run_installer https://install.julialang.org sh -y
fi
have juliaup || die 'Juliaup is unavailable after installation.'
generate_completion juliaup juliaup completions zsh
