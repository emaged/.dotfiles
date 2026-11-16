#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

echo "==> Installing Firefox..."

if apt_has_package firefox; then
  sudo apt-get install -y firefox
else
  sudo apt-get install -y firefox-esr
fi

sudo apt-get install -y geoclue-2.0 xdg-utils

echo "==> Setting Firefox as default browser..."

desktop_id=""
for candidate in firefox.desktop firefox_firefox.desktop firefox-esr.desktop; do
  if [[ -f "/usr/share/applications/$candidate" ]] || [[ -f "/var/lib/snapd/desktop/applications/$candidate" ]]; then
    desktop_id="$candidate"
    break
  fi
done

if [[ -n "$desktop_id" && -n ${DISPLAY:-}${WAYLAND_DISPLAY:-} ]]; then
  xdg-settings set default-web-browser "$desktop_id"
  xdg-mime default "$desktop_id" x-scheme-handler/http
  xdg-mime default "$desktop_id" x-scheme-handler/https
  xdg-mime default "$desktop_id" text/html
else
  echo "No desktop session or Firefox desktop file; skipping default browser setup."
fi

echo "Firefox setup finished."
