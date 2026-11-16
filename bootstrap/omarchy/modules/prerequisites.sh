#!/usr/bin/env bash
set -euo pipefail
command -v yay >/dev/null || { echo 'Omarchy AUR helper yay is required.' >&2; exit 1; }
omarchy pkg add base-devel ca-certificates curl git python unzip xz
