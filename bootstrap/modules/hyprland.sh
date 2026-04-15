#!/usr/bin/env bash
set -euo pipefail

echo "==> installing hyprland plugins ..."

hyprpm update

if ! hyprpm list | grep -q "hyprland-plugins"; then
    hyprpm add https://github.com/hyprwm/hyprland-plugins
else
    echo "→ hyprland-plugins already installed"
fi

echo "hyprland plugins installed"
