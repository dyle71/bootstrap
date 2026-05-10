#!/bin/sh
# Install packages for Ubuntu 24.04 LTS (Noble)
set -e

PACKAGES="git net-tools eza iproute2 zsh curl wget"

echo "Updating package lists..."
sudo apt-get update -q

echo "Installing: ${PACKAGES}"
sudo apt-get install -y ${PACKAGES}

echo "Installing neovim from GitHub releases (apt only provides 0.9)..."
NVIM_TMP=$(mktemp -d)
curl -L --fail "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
    -o "${NVIM_TMP}/nvim.tar.gz"
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf "${NVIM_TMP}/nvim.tar.gz"
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm -rf "${NVIM_TMP}"
