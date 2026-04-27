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
  cargo \
  ca-certificates \
  cmake \
  cpio \
  curl \
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
  rustc \
  software-properties-common \
  tectonic \
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

echo "==> Ensuring apt-file database is initialized..."
sudo apt-file update

echo "Development tools installed."
