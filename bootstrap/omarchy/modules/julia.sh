#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing Julia..."

juliaup_bin="$HOME/.juliaup/bin/juliaup"

if command -v juliaup >/dev/null 2>&1; then
  juliaup_bin="$(command -v juliaup)"
  echo "Juliaup already installed."
elif [[ -x "$juliaup_bin" ]]; then
  echo "Juliaup already installed."
else
  curl -fsSL https://install.julialang.org -o /tmp/julia-install.sh
  sh /tmp/julia-install.sh -y
  rm /tmp/julia-install.sh

  echo "Julia installation complete."
fi

echo "==> Generating Juliaup Zsh completions..."

completion_dir="$HOME/.zfunc"
completion_tmp="$(mktemp)"

if [[ -x "$juliaup_bin" ]]; then
  mkdir -p "$completion_dir"

  if "$juliaup_bin" completions zsh >"$completion_tmp"; then
    install -m 0644 "$completion_tmp" "$completion_dir/_juliaup"
    echo "Juliaup Zsh completions generated."
  else
    echo "Warning: failed to generate Juliaup Zsh completions." >&2
  fi
else
  echo "Warning: Juliaup executable not found at $juliaup_bin." >&2
fi

rm -f "$completion_tmp"
