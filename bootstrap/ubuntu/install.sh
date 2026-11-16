#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM='ubuntu'
DEFAULT_MODULES=(prerequisites mise shell dev-tools uv pipx cargo_packages node julia neovim opencode starship tmux yazi mongodb postman firefox brave vlc wayland)
OPTIONAL_MODULES=(brightness_setup hyprland)
SKIPPABLE_MODULES=(mongodb)
declare -A MODULE_DEPS=(
  [mise]='prerequisites'
  [shell]='prerequisites'
  [dev-tools]='mise'
  [uv]='prerequisites'
  [pipx]='prerequisites'
  [cargo_packages]='prerequisites'
  [node]='mise'
  [julia]='prerequisites'
  [neovim]='mise node pipx'
  [opencode]='node'
  [starship]='prerequisites'
  [tmux]='mise'
  [yazi]='mise'
  [mongodb]='prerequisites'
  [postman]='prerequisites'
  [firefox]='prerequisites'
  [brave]='prerequisites'
  [vlc]='prerequisites'
  [wayland]='prerequisites'
  [brightness_setup]='prerequisites'
  [hyprland]='prerequisites'
)
check_platform() {
  source /etc/os-release
  [[ ${ID:-} == ubuntu ]] || { printf 'This installer requires Ubuntu.\n' >&2; return 2; }
  case ${VERSION_CODENAME:-} in noble|resolute) ;; *) printf 'Supported Ubuntu releases: 24.04 and 26.04 LTS.\n' >&2; return 2 ;; esac
  if [[ -n ${WSL_DISTRO_NAME:-} ]] || grep -qi microsoft /proc/sys/kernel/osrelease; then
    printf 'Use wsl/install.sh inside WSL.\n' >&2; return 2
  fi
}
source "$ROOT_DIR/lib/runner.sh"
bootstrap_main "$@"
