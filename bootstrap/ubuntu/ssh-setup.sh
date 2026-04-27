#!/usr/bin/env bash
set -euo pipefail

echo "==> Enabling systemd user ssh-agent..."

systemctl --user enable --now ssh-agent.service

echo "==> Configuring environment.d for SSH_AUTH_SOCK..."

ENV_DIR="$HOME/.config/environment.d"
ENV_FILE="$ENV_DIR/ssh-agent.conf"

mkdir -p "$ENV_DIR"

if [[ ! -f "$ENV_FILE" ]] || ! grep -q "SSH_AUTH_SOCK" "$ENV_FILE"; then
  echo 'SSH_AUTH_SOCK=${XDG_RUNTIME_DIR}/ssh-agent.socket' > "$ENV_FILE"
  echo "Created $ENV_FILE"
else
  echo "environment.d already configured."
fi

echo "==> Configuring ~/.ssh/config..."

SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

if ! grep -q "AddKeysToAgent yes" "$SSH_CONFIG"; then
  cat >> "$SSH_CONFIG" <<'EOF'

Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519
EOF
  echo "Updated ~/.ssh/config"
else
  echo "~/.ssh/config already configured."
fi

echo
echo "✅ SSH setup complete."
echo
echo "Next steps:"
echo "  1) Log out and log back in (or reboot)"
echo "  2) Run: ssh your-server"
echo
echo "You will enter your passphrase once per boot."
echo "No more manual ssh-add required."
