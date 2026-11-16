#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
ensure_mise_tool node
ensure_user_npm_prefix
if ! npm list -g --depth=0 opencode-ai >/dev/null 2>&1; then
  npm install -g opencode-ai
fi
