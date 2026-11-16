#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
if ! have mise; then
  run_installer https://mise.run sh
fi
have mise || die 'mise installation failed.'
echo 'mise is available. Modules use the home configuration without interactive shell activation.'
