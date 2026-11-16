#!/usr/bin/env bash
# Helpers are deliberately kept inside each platform's installer directory.
BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$HOME/.local/bin:${CARGO_HOME:-$HOME/.cargo}/bin:${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims:$PATH"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

load_packages() {
  local line file="$BOOTSTRAP_DIR/packages/$1.txt"
  [[ -r $file ]] || die "Missing package list: $file"
  packages=()
  while IFS= read -r line || [[ -n $line ]]; do
    line=${line%$'\r'}
    [[ -n $line && $line != \#* ]] || continue
    [[ $line != *[[:space:]]* ]] || die "Invalid package name in $file: $line"
    packages+=("$line")
  done < "$file"
  ((${#packages[@]})) || die "Empty package list: $file"
}

run_installer() (
  local url=$1 interpreter=$2 installer
  shift 2
  installer=$(mktemp)
  trap 'rm -f -- "$installer"' EXIT
  curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 \
    --retry 3 "$url" --output "$installer"
  "$interpreter" "$installer" "$@"
)

mise_tool_configured() {
  local inventory
  inventory=$(mise -C "$HOME" ls --current "$1" --json) || return
  /usr/bin/python3 -c 'import json,sys; data=json.load(sys.stdin); print("yes" if data else "no")' <<<"$inventory"
}

ensure_mise_tool() {
  local tool=$1 version=${2:-latest} configured directory
  configured=$(mise_tool_configured "$tool")
  if [[ $configured == yes ]]; then
    # Preserve global/system constraints, including Omarchy's lazy tools.
    if ! mise -C "$HOME" where "$tool" >/dev/null 2>&1; then
      mise -C "$HOME" install "$tool"
    fi
  else
    mise -C "$HOME" use -g "$tool@$version"
  fi
  directory=$(mise -C "$HOME" where "$tool")
  export PATH="$directory/bin:$directory:$PATH"
}

ensure_user_npm_prefix() {
  local prefix directory
  prefix=$(npm prefix -g)
  case "$prefix" in /|/usr|/usr/local|/opt|/opt/*) die "npm prefix $prefix is system-managed; select a user-owned Node installation." ;; esac
  [[ -d $prefix && -O $prefix && -w $prefix ]] || die "npm prefix is not user-owned and writable: $prefix"
  for directory in "$prefix/bin" "$prefix/lib" "$prefix/lib/node_modules"; do
    if [[ -e $directory ]]; then
      [[ -d $directory && -O $directory && -w $directory ]] || die "npm directory is not user-owned and writable: $directory"
    fi
  done
  export PATH="$prefix/bin:$PATH"
}

generate_completion() (
  local name=$1 temporary
  shift
  temporary=$(mktemp)
  trap 'rm -f -- "$temporary"' EXIT
  "$@" > "$temporary"
  mkdir -p "$HOME/.zfunc"
  install -m 0644 "$temporary" "$HOME/.zfunc/_$name"
)

link_command() {
  local name=$1 target=$2 destination="$HOME/.local/bin/$1"
  have "$name" && return 0
  [[ -e $destination || -L $destination ]] && die "Refusing to replace $destination"
  [[ -x $target ]] || die "Command target does not exist: $target"
  mkdir -p "$HOME/.local/bin"
  ln -s -- "$target" "$destination"
}

apt_has_package() {
  local policy
  policy=$(LC_ALL=C apt-cache policy "$1") || return
  [[ $policy =~ Candidate:[[:space:]]+([^[:space:]]+) && ${BASH_REMATCH[1]} != '(none)' ]]
}

install_cargo_packages() {
  local crate binary installed resolved
  local -a cargo_command=(cargo)
  if have rustup; then
    if ! rustup run stable cargo --version >/dev/null 2>&1; then
      rustup toolchain install stable --profile minimal
    fi
    cargo_command=(rustup run stable cargo)
  fi
  installed=$("${cargo_command[@]}" install --list)
  load_packages cargo
  for crate in "${packages[@]}"; do
    case "$crate" in
      cargo-update) binary=cargo-install-update ;;
      du-dust) binary=dust ;;
      *) binary=$crate ;;
    esac
    if grep -q "^${crate} v" <<<"$installed"; then
      printf '%s already installed through Cargo\n' "$crate"
    elif have pacman && resolved=$(command -v "$binary") && pacman -Qo "$resolved" >/dev/null 2>&1; then
      printf '%s is managed by pacman\n' "$crate"
    else
      "${cargo_command[@]}" install "$crate" --locked
    fi
  done
}
