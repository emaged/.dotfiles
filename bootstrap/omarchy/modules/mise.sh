#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
have mise || omarchy pkg add mise-bin
have mise || die 'mise installation failed.'
