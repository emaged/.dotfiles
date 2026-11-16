#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM='Ubuntu on WSL'
DEFAULT_MODULES=(prerequisites mise shell dev-tools uv pipx cargo_packages node julia neovim opencode starship tmux yazi mongodb)
OPTIONAL_MODULES=()
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
)
check_platform() {
  source /etc/os-release
  [[ ${ID:-} == ubuntu ]] || { printf 'This installer requires Ubuntu.\n' >&2; return 2; }
  case ${VERSION_CODENAME:-} in noble|resolute) ;; *) printf 'Supported Ubuntu releases: 24.04 and 26.04 LTS.\n' >&2; return 2 ;; esac
  if [[ -z ${WSL_DISTRO_NAME:-} ]] && ! grep -qi microsoft /proc/sys/kernel/osrelease; then
    printf 'This installer requires Ubuntu inside WSL. Use ubuntu/install.sh on a desktop.\n' >&2; return 2
  fi
}
source "$ROOT_DIR/lib/runner.sh"
bootstrap_main "$@"
