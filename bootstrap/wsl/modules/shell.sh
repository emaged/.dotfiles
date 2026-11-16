#!/usr/bin/env bash
set -euo pipefail
sudo apt-get install -y zsh
zsh_path=$(command -v zsh)
if ! grep -Fxq "$zsh_path" /etc/shells; then
  printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
fi
user_name=$(id -un)
login_shell=$(getent passwd "$user_name" | cut -d: -f7)
if [[ $login_shell != "$zsh_path" ]]; then
  chsh -s "$zsh_path" "$user_name"
  echo 'Default shell changed to zsh. Log out and back in.'
else
  echo 'zsh is already the login shell.'
fi
