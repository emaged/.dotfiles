#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
if ! have uv; then
  run_installer https://astral.sh/uv/install.sh sh
fi
have uv || die 'uv is unavailable after installation.'
