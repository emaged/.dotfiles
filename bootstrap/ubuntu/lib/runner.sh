#!/usr/bin/env bash
# Local to this platform: entry points supply module lists and dependencies.

usage() {
  printf 'Usage: %s [--dry-run] [MODULE ...]\n' "$0"
  printf '%s\n' '  --help     Show usage.' '  --list     List default and optional modules.' \
    '  --dry-run  Print module order, including prerequisites; make no changes.' \
    'Without module names, install the default set. Optional modules require explicit selection.'
}

bootstrap_main() {
  local arg module status
  local dry_run=false
  local -a requested=() plan=() skipped=()
  local -A known=() visiting=() planned=()
  for module in "${DEFAULT_MODULES[@]}" "${OPTIONAL_MODULES[@]}"; do
    known["$module"]=1
  done
  for arg in "$@"; do
    case "$arg" in
      -h|--help) usage; return 0 ;;
      --list)
        printf 'Default modules:\n'; printf '  %s\n' "${DEFAULT_MODULES[@]}"
        printf 'Optional modules:\n'; printf '  %s\n' "${OPTIONAL_MODULES[@]}"
        return 0 ;;
      -n|--dry-run) dry_run=true ;;
      -*) printf 'Unknown option: %s\n' "$arg" >&2; return 2 ;;
      *) requested+=("${arg%.sh}") ;;
    esac
  done
  if ((${#requested[@]} == 0)); then
    requested=("${DEFAULT_MODULES[@]}")
  fi
  for module in "${requested[@]}"; do
    if [[ ! $module =~ ^[a-z][a-z0-9_-]*$ ]] || [[ ! ${known[$module]:-} ]]; then
      printf 'Unknown module: %s (use --list)\n' "$module" >&2
      return 2
    fi
  done

  add_module() {
    local module=$1 dependency
    [[ ! ${planned[$module]:-} ]] || return 0
    if [[ ${visiting[$module]:-} || ! ${known[$module]:-} ]]; then
      printf 'Invalid module dependency: %s\n' "$module" >&2
      return 2
    fi
    visiting["$module"]=1
    for dependency in ${MODULE_DEPS[$module]:-}; do
      add_module "$dependency" || return
    done
    unset 'visiting[$module]'
    [[ -f "$ROOT_DIR/modules/$module.sh" ]] || {
      printf 'Missing module: %s\n' "$module" >&2; return 2;
    }
    planned["$module"]=1
    plan+=("$module")
  }
  for module in "${requested[@]}"; do
    add_module "$module" || return
  done
  printf '%s bootstrap module order:\n' "$PLATFORM"
  printf '  %s\n' "${plan[@]}"
  if $dry_run; then
    printf 'Preview only: no modules, package checks or downloads were run.\n'
    return 0
  fi
  if ((EUID == 0)); then
    printf 'Run as your normal user, without sudo. Modules request sudo when needed.\n' >&2
    return 2
  fi
  check_platform
  for module in "${plan[@]}"; do
    printf '\n==> %s\n' "$module"
    # A separate Bash process preserves errexit inside each module.
    if (cd "$HOME" && bash "$ROOT_DIR/modules/$module.sh"); then
      continue
    else
      status=$?
    fi
    if [[ $status == 3 && " ${SKIPPABLE_MODULES[*]} " == *" $module "* ]]; then
      skipped+=("$module")
    else
      printf '\nFAILED: %s (exit %s). Bootstrap stopped.\n' "$module" "$status" >&2
      return "$status"
    fi
  done
  if ((${#skipped[@]})); then
    printf '\nBootstrap finished with optional modules skipped: %s\n' "${skipped[*]}"
  else
    printf '\nBootstrap complete.\n'
  fi
}
