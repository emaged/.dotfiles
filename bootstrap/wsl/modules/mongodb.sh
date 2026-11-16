#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"
source /etc/os-release
# Never mix Ubuntu suites implicitly. The MongoDB 8.0 repository supports Noble.
if [[ ${VERSION_CODENAME:-} != noble ]]; then
  echo "SKIP: MongoDB 8.0 tools have no supported repository configured for ${VERSION_CODENAME:-unknown}." >&2
  echo 'Install the vendor-supported standalone tools for this release; see README.md.' >&2
  exit 3
fi
architecture=$(dpkg --print-architecture)
case "$architecture" in amd64|arm64) ;; *) die "Unsupported MongoDB architecture: $architecture" ;; esac
key_dir=$(mktemp -d)
trap 'rm -f -- "$key_dir/key.asc" "$key_dir/key.gpg"; rmdir -- "$key_dir"' EXIT
curl -fsSL https://pgp.mongodb.com/server-8.0.asc -o "$key_dir/key.asc"
gpg --batch --yes --dearmor --output "$key_dir/key.gpg" "$key_dir/key.asc"
sudo install -d -m 0755 /etc/apt/keyrings
sudo install -m 0644 "$key_dir/key.gpg" /etc/apt/keyrings/mongodb-server-8.0.gpg
printf 'deb [arch=%s signed-by=/etc/apt/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse\n' "$architecture" |
  sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list >/dev/null
sudo apt-get update
sudo apt-get install -y mongodb-atlas-cli mongodb-database-tools mongodb-mongosh
