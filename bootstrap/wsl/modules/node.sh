#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
ensure_mise_tool node
have npm || die 'npm is unavailable after installing Node.'
ensure_user_npm_prefix
load_packages npm
for package in "${packages[@]}"; do
  if npm list -g --depth=0 "$package" >/dev/null 2>&1; then
    printf '%s already installed\n' "$package"
  else
    npm install -g -- "$package"
  fi
done
generate_completion codex codex completion zsh
