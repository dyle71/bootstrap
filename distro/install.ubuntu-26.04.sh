#!/bin/sh
# Install packages for Ubuntu 26.04 LTS (Questing)
set -e

PACKAGES="neovim git net-tools eza git-delta iproute2 zsh curl wget fd-find ripgrep ncdu"

echo "Updating package lists..."
sudo apt-get update -q

echo "Installing: ${PACKAGES}"
sudo apt-get install -y ${PACKAGES}

# Debian/Ubuntu ship fd as 'fdfind' (name clash with another package) - provide 'fd'.
echo "Linking fdfind to /usr/local/bin/fd ..."
sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
