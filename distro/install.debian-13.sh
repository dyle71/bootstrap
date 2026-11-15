#!/bin/sh
# Install packages for Debian 13 (Trixie)
set -e

PACKAGES="git net-tools eza git-delta iproute2 zsh curl wget fd-find ripgrep ncdu"

echo "Updating package lists..."
sudo apt-get update -q

echo "Installing: ${PACKAGES}"
sudo apt-get install -y ${PACKAGES}

echo "Installing neovim from GitHub releases (apt only provides 0.10)..."
NVIM_TMP=$(mktemp -d)
curl -L --fail "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
    -o "${NVIM_TMP}/nvim.tar.gz"
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf "${NVIM_TMP}/nvim.tar.gz"
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm -rf "${NVIM_TMP}"

# Debian/Ubuntu ship fd as 'fdfind' (name clash with another package) - provide 'fd'.
echo "Linking fdfind to /usr/local/bin/fd ..."
sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
