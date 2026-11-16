#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
if ! have pipx; then
  omarchy pkg add python-pipx
fi
pipx ensurepath
inventory=$(pipx list --json)
installed=$(/usr/bin/python3 -c 'import json,sys; print("\n".join(json.load(sys.stdin)["venvs"]))' <<<"$inventory")
load_packages pipx
for package in "${packages[@]}"; do
  if grep -Fxq -- "$package" <<<"$installed"; then
    pipx upgrade "$package"
  else
    pipx install "$package"
  fi
done
