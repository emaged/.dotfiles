#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing global npm packages..."

if ! command -v npm &>/dev/null; then
  echo "npm not found. Make sure mise has installed node."
  exit 1
fi

packages=(
  "@openai/codex"
  browser-sync
  eslint_d
  eslint-config-prettier
  eslint
  htmlhint
  http-server
  live-server
  mcp-hub
  @mermaid-js/mermaid-cli
  neovim
  prettier
)

for pkg in "${packages[@]}"; do
  if npm list -g --depth=0 "$pkg" >/dev/null 2>&1; then
    echo "$pkg already installed"
  else
    echo "Installing $pkg..."
    npm install -g "$pkg"
  fi
done

echo "==> Generating Codex Zsh completions..."

codex_bin="$(npm prefix -g)/bin/codex"
completion_dir="$HOME/.zfunc"
completion_tmp="$(mktemp)"

if [[ -x "$codex_bin" ]]; then
  mkdir -p "$completion_dir"

  if "$codex_bin" completion zsh >"$completion_tmp"; then
    install -m 0644 "$completion_tmp" "$completion_dir/_codex"
    echo "Codex Zsh completions generated."
  else
    echo "Warning: failed to generate Codex Zsh completions." >&2
  fi
else
  echo "Warning: global Codex executable not found at $codex_bin." >&2
fi

rm -f "$completion_tmp"

echo "Global npm packages installation complete."
