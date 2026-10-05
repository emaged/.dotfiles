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

echo "==> Installing Omarchy plugins..."

install_plugin omaplug https://github.com/fross100/omaplug.git
install_plugin jankeesvw.notification-center https://github.com/jankeesvw/omarchy-notification-center.git
install_plugin marcho78.titlebars https://github.com/marcho78/omarchy-titlebars.git

# Setup is safe to repeat and builds hyprbars for the installed Hyprland version.
echo "==> Setting up Title Bars..."
"$PLUGINS_DIR/marcho78.titlebars/bin/titlebars" setup

echo "Omarchy plugin setup complete."
