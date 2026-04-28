#!/usr/bin/env bash
set -euo pipefail

target="/mnt/c/Users/emiel/Dropbox"
link="$HOME/Dropbox"

if [[ ! -e "$target" ]]; then
  echo "Target does not exist: $target" >&2
  exit 1
fi

if [[ -L "$link" ]]; then
  current_target="$(readlink "$link")"
  if [[ "$current_target" == "$target" ]]; then
    echo "Dropbox symlink already correct: $link -> $target"
    exit 0
  fi

  echo "Refusing to replace existing symlink: $link -> $current_target" >&2
  exit 1
fi

if [[ -e "$link" ]]; then
  echo "Refusing to replace existing path: $link" >&2
  exit 1
fi

ln -s "$target" "$link"
echo "Created symlink: $link -> $target"
