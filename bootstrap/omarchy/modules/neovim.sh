#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
echo '==> Installing Neovim nightly...'
omarchy pkg aur add neovim-nightly-bin
omarchy pkg add ruby luarocks
if ! gem list -i neovim >/dev/null 2>&1; then
  gem install --user-install neovim --no-document
fi
gem_user_dir=$(ruby -r rubygems -e 'print Gem.user_dir')
if [[ -x "$gem_user_dir/bin/neovim-ruby-host" ]]; then
  link_command neovim-ruby-host "$gem_user_dir/bin/neovim-ruby-host"
fi
