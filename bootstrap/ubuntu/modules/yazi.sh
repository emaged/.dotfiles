#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
sudo apt-get install -y ffmpeg 7zip file fd-find imagemagick jq poppler-utils ripgrep wl-clipboard zoxide
link_command fd /usr/bin/fdfind
# Noble's fzf is older than Yazi's minimum; mise provides a current binary.
ensure_mise_tool fzf
ensure_mise_tool yazi
ensure_mise_tool resvg
if ! command -v magick >/dev/null 2>&1; then
  echo 'NOTE: ImageMagick 6 provides reduced Yazi previews. Full font/HEIC/JXL previews require ImageMagick 7.1.1+.' >&2
fi
