#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
[[ -d /run/systemd/system ]] || die 'Postman via Snap requires systemd; use the WSL installer inside WSL.'
sudo apt-get install -y snapd
sudo systemctl enable --now snapd.socket
if ! snap list postman >/dev/null 2>&1; then
  sudo snap install postman
fi
