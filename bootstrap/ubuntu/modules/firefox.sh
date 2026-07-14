#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Firefox..."

if apt-cache show firefox >/dev/null 2>&1; then
  sudo apt install -y firefox
else
  sudo apt install -y firefox-esr
fi

sudo apt install -y geoclue-2.0

echo "==> Setting Firefox as default browser..."

desktop_id=""
for candidate in firefox.desktop firefox_firefox.desktop firefox-esr.desktop; do
  if [[ -f "/usr/share/applications/$candidate" ]] || [[ -f "/var/lib/snapd/desktop/applications/$candidate" ]]; then
    desktop_id="$candidate"
    break
  fi
done

if [[ -n "$desktop_id" ]]; then
  xdg-settings set default-web-browser "$desktop_id" || true
  xdg-mime default "$desktop_id" x-scheme-handler/http || true
  xdg-mime default "$desktop_id" x-scheme-handler/https || true
  xdg-mime default "$desktop_id" text/html || true
else
  echo "Firefox desktop file not found; skipping default browser setup."
fi

echo "Firefox installation and default configuration complete."
