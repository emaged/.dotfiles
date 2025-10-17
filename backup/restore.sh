#!/bin/bash

BACKUP_DIR="$HOME/.dotfiles/backup"

echo "Restoring APT packages..."
if [ -f "$BACKUP_DIR/apt-packages-list.txt" ]; then
    sudo dpkg --set-selections < "$BACKUP_DIR/apt-packages-list.txt"
    sudo apt-get update
    sudo apt-get dselect-upgrade -y
fi

echo "Restoring Snap packages..."
if [ -f "$BACKUP_DIR/snap-packages-list.txt" ]; then
    xargs -a "$BACKUP_DIR/snap-packages-list.txt" sudo snap install
fi

echo "Restoring Flatpak packages..."
if [ -f "$BACKUP_DIR/flatpak-packages-list.txt" ]; then
    xargs -a "$BACKUP_DIR/flatpak-packages-list.txt" flatpak install -y
fi

echo "Restoring PIP packages..."
if [ -f "$BACKUP_DIR/pip-packages.txt" ]; then
    pip3 install -r "$BACKUP_DIR/pip-packages.txt"
fi

echo "Restoring Cargo packages..."
if [ -f "$BACKUP_DIR/cargo-packages-list.txt" ]; then
    awk '{print $1}' "$BACKUP_DIR/cargo-packages-list.txt" | xargs cargo install
fi

echo "Restoring NPM global packages..."
if [ -f "$BACKUP_DIR/npm-global-packages.txt" ]; then
    xargs -a "$BACKUP_DIR/npm-global-packages.txt" npm install -g
fi

echo "Restoring Go binaries..."
if [ -f "$BACKUP_DIR/go-packages-list.txt" ]; then
    while read pkg; do
        go install "$pkg@latest"
    done < "$BACKUP_DIR/go-packages-list.txt"
fi

echo "Restoring Ruby Gems..."
if [ -f "$BACKUP_DIR/gem-packages-list.txt" ]; then
    xargs -a "$BACKUP_DIR/gem-packages-list.txt" gem install
fi

echo "Restore complete!"

