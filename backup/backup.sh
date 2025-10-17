#!/bin/bash

# Create backup directory
BACKUP_DIR="$HOME/.dotfiles/backup"
mkdir -p "$BACKUP_DIR"

echo "Backing up APT packages..."
dpkg --get-selections > "$BACKUP_DIR/apt-packages-list.txt"

echo "Backing up Snap packages..."
snap list | awk 'NR>1 {print $1}' > "$BACKUP_DIR/snap-packages-list.txt"

echo "Backing up Flatpak packages..."
flatpak list --app --columns=application > "$BACKUP_DIR/flatpak-packages-list.txt"

echo "Backing up PIP packages..."
pip3 freeze > "$BACKUP_DIR/pip-packages.txt"

echo "Backing up Cargo packages..."
cargo install --list > "$BACKUP_DIR/cargo-packages-list.txt"

echo "Backing up NPM global packages..."
npm list -g --depth=0 | tail -n +2 | awk -F ' ' '{print $1}' > "$BACKUP_DIR/npm-global-packages.txt"

echo "Backing up Go binaries..."
GO_BIN=$(go env GOPATH)/bin
if [ -d "$GO_BIN" ]; then
    ls "$GO_BIN" > "$BACKUP_DIR/go-packages-list.txt"
fi

echo "Backing up Ruby Gems..."
gem list | awk '{print $1}' > "$BACKUP_DIR/gem-packages-list.txt"

echo "Backup complete! All files are in $BACKUP_DIR"

