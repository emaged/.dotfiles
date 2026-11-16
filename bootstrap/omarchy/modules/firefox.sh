#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

echo "==> Installing Firefox..."

omarchy pkg add firefox
omarchy pkg add firefox-developer-edition
omarchy pkg add geoclue

if [[ -z ${DISPLAY:-}${WAYLAND_DISPLAY:-} ]]; then
  echo 'Firefox installed. No desktop session; skipping default browser setup.'
  exit 0
fi
echo "==> Setting Firefox as default browser..."

# Set default browser via xdg
xdg-settings set default-web-browser firefox.desktop

# Also ensure common URL handlers are mapped
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https
xdg-mime default firefox.desktop text/html

echo "Firefox setup finished."
