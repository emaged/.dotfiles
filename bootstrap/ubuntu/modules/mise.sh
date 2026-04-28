#!/usr/bin/env bash

ensure_mise() {
  export PATH="$HOME/.local/bin:$PATH"

  if ! command -v mise >/dev/null 2>&1; then
    echo "==> Installing mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  if ! command -v mise >/dev/null 2>&1; then
    echo "mise installation failed."
    exit 1
  fi

  echo "mise available for installation..."
  eval "$(mise activate bash)"
}
