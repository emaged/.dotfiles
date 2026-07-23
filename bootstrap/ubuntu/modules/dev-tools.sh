#!/usr/bin/env bash
set -euo pipefail

apt_has_package() {
    apt-cache show "$1" >/dev/null 2>&1
}

install_available_packages() {
    local available=()
    local missing=()
    local pkg

    for pkg in "$@"; do
        if apt_has_package "$pkg"; then
            available+=("$pkg")
        else
            missing+=("$pkg")
        fi
    done

    if ((${#available[@]})); then
        sudo apt install -y "${available[@]}"
    fi

    if ((${#missing[@]})); then
        echo "Skipping unavailable packages: ${missing[*]}"
    fi
}

echo "==> Installing development tools..."

sudo apt update

install_available_packages \
    apt-file \
    bat \
    bc \
    bottom \
    ca-certificates \
    cmake \
    cpio \
    curl \
    eza \
    fd-find \
    gdu \
    git-delta \
    glab \
    gnupg \
    imagemagick \
    inotify-tools \
    lua5.1 \
    maven \
    meson \
    mkcert \
    ninja-build \
    openjfx \
    openjfx-source \
    python3 \
    ripgrep \
    ruby-full \
    snapd \
    software-properties-common \
    texlive-latex-base \
    udiskie \
    wev \
    wget \
    zoxide

install_available_packages \
    openjdk-21-jdk \
    openjdk-21-source \
    openjdk-17-jdk \
    openjdk-17-source \
    openjdk-11-jdk \
    openjdk-11-source \
    openjdk-8-jdk \
    openjdk-8-source

echo "==> Configuring the MongoDB 8.0 package repository..."
. /etc/os-release

case "${VERSION_CODENAME:-}" in
    noble|jammy|focal) ;;
    *)
        echo "Unsupported Ubuntu release: ${VERSION_CODENAME:-unknown}"
        exit 1
        ;;
esac

curl -fsSL https://pgp.mongodb.com/server-8.0.asc |
    sudo gpg --dearmor --yes \
        --output /usr/share/keyrings/mongodb-server-8.0.gpg

echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu ${VERSION_CODENAME}/mongodb-org/8.0 multiverse" |
    sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list >/dev/null

sudo apt update
sudo apt install -y \
    mongodb-atlas-cli \
    mongodb-database-tools \
    mongodb-mongosh

echo "==> Installing Postman..."
if ! snap list postman &>/dev/null; then
    sudo snap install postman
else
    echo "Postman already installed."
fi

echo "==> Ensuring apt-file database is initialized..."
sudo apt-file update

echo "Development tools installed."
