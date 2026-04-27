#!/usr/bin/env bash
set -euo pipefail

echo "==> installing hyprland plugins ..."

if ! command -v hyprpm >/dev/null 2>&1; then
  echo "hyprpm not found, skipping hyprland plugin setup."
  exit 0
fi

hyprpm update

if ! hyprpm list | grep -q "hyprland-plugins"; then
  hyprpm add https://github.com/hyprwm/hyprland-plugins
else
  echo "→ hyprland-plugins already installed"
fi

hyprpm update

echo "hyprland plugins installed"
