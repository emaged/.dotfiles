#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/lib/common.sh"
((EUID != 0)) || die 'Run SSH setup as your normal user.'
have ssh-agent || die 'Install openssh-client (Ubuntu/WSL) or openssh (Omarchy) first.'
[[ -n ${XDG_RUNTIME_DIR:-} ]] || die 'A systemd user session is required (enable systemd in WSL first).'
systemctl --user show-environment >/dev/null || die 'No systemd user session is available.'
expected_socket="$XDG_RUNTIME_DIR/ssh-agent.socket"
if [[ -n ${SSH_AUTH_SOCK:-} && $SSH_AUTH_SOCK != "$expected_socket" ]]; then
  die 'SSH_AUTH_SOCK already selects another agent. Keep that agent or resolve the conflict explicitly.'
fi
[[ -z ${SSH_AGENT_PID:-} ]] || die 'An SSH agent is already running in this shell.'
if systemctl --user is-enabled --quiet gcr-ssh-agent.socket 2>/dev/null; then
  die 'gcr-ssh-agent is already enabled. This helper will not replace it.'
fi

environment_file="$HOME/.config/environment.d/ssh-agent.conf"
environment_line='SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket'
if [[ -e $environment_file || -L $environment_file ]]; then
  grep -Fxq "$environment_line" "$environment_file" || die "Refusing to replace existing $environment_file"
fi

if socket_unit=$(systemctl --user cat ssh-agent.socket 2>/dev/null); then
  grep -Fxq 'ListenStream=%t/ssh-agent.socket' <<<"$socket_unit" || die 'The native agent socket uses an unexpected path.'
  unit=ssh-agent.socket
else
  # Ubuntu 24.04 has no socket unit; its graphical-session service is unsuitable for WSL.
  if systemctl --user is-active --quiet ssh-agent.service; then
    die 'The native ssh-agent.service is already running. Resolve the existing agent before using this helper.'
  fi
  unit=dotfiles-ssh-agent.service
  unit_file="$HOME/.config/systemd/user/$unit"
  if [[ -e $unit_file || -L $unit_file ]]; then
    cmp -s "$ROOT_DIR/files/$unit" "$unit_file" || die "Refusing to replace existing $unit_file"
  else
    install -Dm644 "$ROOT_DIR/files/$unit" "$unit_file"
  fi
  systemctl --user daemon-reload
fi

if [[ ! -e $environment_file ]]; then
  mkdir -p "$(dirname "$environment_file")"
  printf '%s\n' "$environment_line" > "$environment_file"
fi
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh_config="$HOME/.ssh/config"
# Append defaults without choosing a private key or replacing existing host settings.
if [[ ! -f $ssh_config ]] || ! grep -Fxq '# dotfiles bootstrap: SSH agent' "$ssh_config"; then
  cat >> "$ssh_config" <<'EOF'

# dotfiles bootstrap: SSH agent
Host *
    AddKeysToAgent yes
EOF
fi
chmod 600 "$ssh_config"
systemctl --user enable --now "$unit"
echo 'SSH agent setup complete. Log out and back in to load SSH_AUTH_SOCK.'
