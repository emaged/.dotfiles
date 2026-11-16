#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM='omarchy'
DEFAULT_MODULES=(prerequisites mise shell dev-tools uv pipx cargo_packages npm julia neovim opencode starship tmux yazi firefox brave vlc wayland)
OPTIONAL_MODULES=(brightness_setup omarchy-plugins hyprland)
SKIPPABLE_MODULES=()
declare -A MODULE_DEPS=(
  [mise]='prerequisites'
  [shell]='prerequisites'
  [dev-tools]='prerequisites'
  [uv]='mise'
  [pipx]='prerequisites'
  [cargo_packages]='prerequisites'
  [npm]='mise'
  [julia]='prerequisites'
  [neovim]='npm pipx'
  [opencode]='mise'
  [starship]='prerequisites'
  [tmux]='prerequisites'
  [yazi]='prerequisites'
  [firefox]='prerequisites'
  [brave]='prerequisites'
  [vlc]='prerequisites'
  [wayland]='prerequisites'
  [brightness_setup]='prerequisites'
  [omarchy-plugins]='prerequisites'
  [hyprland]='prerequisites'
)
check_platform() {
  command -v omarchy >/dev/null && command -v pacman >/dev/null || {
    printf 'This installer requires an existing Omarchy installation.\n' >&2; return 2;
  }
}
source "$ROOT_DIR/lib/runner.sh"
bootstrap_main "$@"
