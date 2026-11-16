#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
# Keep the distro package for runtime libraries; use a recent tmux for these dotfiles.
sudo apt-get install -y git tmux
ensure_mise_tool tmux
version=$(tmux -V)
version=${version#tmux }
if ! dpkg --compare-versions "$version" ge 3.6; then
  die "tmux $version is pinned below the dotfiles minimum (3.6). Select a compatible version in mise."
fi
plugins="$HOME/.config/tmux/plugins"
mkdir -p "$plugins"
for plugin in tpm tmux-powerkit; do
  case "$plugin" in
    tpm) url=https://github.com/tmux-plugins/tpm.git ;;
    tmux-powerkit) url=https://github.com/fabioluciano/tmux-powerkit.git ;;
  esac
  if [[ -d "$plugins/$plugin/.git" ]]; then
    printf '%s already installed\n' "$plugin"
  elif [[ -e "$plugins/$plugin" || -L "$plugins/$plugin" ]]; then
    die "Refusing to replace $plugins/$plugin"
  else
    git clone "$url" "$plugins/$plugin"
  fi
done
echo 'tmux plugins match the dotfiles configuration. Existing plugin checkouts were retained.'
