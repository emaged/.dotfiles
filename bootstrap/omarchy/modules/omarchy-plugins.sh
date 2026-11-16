#!/usr/bin/env bash
set -euo pipefail

# Run from an active Omarchy desktop session so plugins can be enabled.
PLUGINS_DIR="$HOME/.config/omarchy/plugins"

if ! command -v omarchy &>/dev/null; then
  echo "Omarchy is required to install shell plugins." >&2
  exit 1
fi

install_plugin() {
  local id="$1"
  local url="$2"

  if [[ -d "$PLUGINS_DIR/$id" ]]; then
    echo "$id already installed"
    return
  fi

  omarchy plugin add "$url" --enable --yes
}

[[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] || {
  echo 'Run this optional module from an active Omarchy desktop session.' >&2
  exit 1
}
echo "==> Installing Omarchy plugins..."

install_plugin omaplug https://github.com/fross100/omaplug.git
install_plugin jankeesvw.notification-center https://github.com/jankeesvw/omarchy-notification-center.git
if pacman -Q omarchy-hyprland-titlebars >/dev/null 2>&1; then
  echo 'Omarchy supplies titlebars; skipping legacy hyprbars setup.'
else
  install_plugin marcho78.titlebars https://github.com/marcho78/omarchy-titlebars.git
  "$PLUGINS_DIR/marcho78.titlebars/bin/titlebars" setup
fi

echo "Omarchy plugin setup complete."
