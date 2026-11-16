#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
sudo apt-get install -y ruby-full ruby-dev build-essential luarocks python3 python3-venv unzip xz-utils
ensure_mise_tool neovim nightly
# Install the provider as the user and expose its executable without sudo gem.
if ! gem list -i neovim >/dev/null 2>&1; then
  gem install --user-install neovim --no-document
fi
gem_user_dir=$(ruby -r rubygems -e 'print Gem.user_dir')
if [[ -x "$gem_user_dir/bin/neovim-ruby-host" ]]; then
  link_command neovim-ruby-host "$gem_user_dir/bin/neovim-ruby-host"
fi
nvim --version
