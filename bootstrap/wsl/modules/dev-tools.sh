#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
echo '==> Installing development tools...'
# Java 25 is required by the Eclipse bundles shipped with JDT LS.
sudo apt-get install -y apt-file bat bc btm cmake cpio fd-find gnupg \
  imagemagick inotify-tools lua5.1 maven meson mkcert ninja-build openjdk-25-jdk python3 \
  ruby-full ruby-dev build-essential ripgrep wget zoxide software-properties-common texlive-latex-base

# These packages vary between LTS archives; retain the same CLI capabilities.
for tool in eza gdu glab lazygit; do
  if apt_has_package "$tool"; then
    sudo apt-get install -y "$tool"
  else
    ensure_mise_tool "$tool"
  fi
done
if apt_has_package git-delta; then
  sudo apt-get install -y git-delta
else
  ensure_mise_tool delta
fi

if apt_has_package tectonic; then
  sudo apt-get install -y tectonic
else
  ensure_mise_tool github:tectonic-typesetting/tectonic
fi

optional_missing=()
for version in 21 17 11 8; do
  for suffix in jdk source; do
    package="openjdk-$version-$suffix"
    if apt_has_package "$package"; then
      sudo apt-get install -y "$package"
    else
      optional_missing+=("$package")
    fi
  done
done
if ((${#optional_missing[@]})); then
  printf 'Optional Java packages unavailable in this release: %s\n' "${optional_missing[*]}"
fi

link_command bat /usr/bin/batcat
link_command fd /usr/bin/fdfind
sudo apt-file update
echo 'Development tools installed.'
