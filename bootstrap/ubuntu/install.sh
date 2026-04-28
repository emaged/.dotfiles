#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$ROOT_DIR/modules"

run() {
    echo
    echo "==> $1"
    "$MODULE_DIR/$1"
}

echo "==> Refreshing apt package lists..."
sudo apt update

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/modules/mise.sh"

echo "==> ensuring mise..."
ensure_mise

run shell.sh
run dev-tools.sh
run uv.sh
run pipx.sh
run cargo_packages.sh
run node.sh
run julia.sh
run neovim.sh
run opencode.sh
run starship.sh
run tmux.sh
run yazi.sh
run firefox.sh
run brave.sh
run wayland.sh
# run brightness_setup.sh

echo
echo "Bootstrap complete."
