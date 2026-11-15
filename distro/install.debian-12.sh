#!/bin/sh
# Install packages for Debian 12 (Bookworm)
set -e

PACKAGES="git net-tools eza iproute2 zsh curl wget fd-find ripgrep ncdu"

echo "Updating package lists..."
sudo apt-get update -q

echo "Installing: ${PACKAGES}"
sudo apt-get install -y ${PACKAGES}

echo "Installing neovim from GitHub releases (apt only provides 0.7)..."
NVIM_TMP=$(mktemp -d)
curl -L --fail "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
    -o "${NVIM_TMP}/nvim.tar.gz"
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf "${NVIM_TMP}/nvim.tar.gz"
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
rm -rf "${NVIM_TMP}"

echo "Installing git-delta from GitHub releases (not packaged in apt)..."
DELTA_VERSION=$(basename "$(curl -Ls --fail -o /dev/null -w '%{url_effective}' "https://github.com/dandavison/delta/releases/latest")")
DELTA_TMP=$(mktemp -d)
curl -L --fail "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    -o "${DELTA_TMP}/delta.tar.gz"
tar -C "${DELTA_TMP}" --strip-components=1 -xzf "${DELTA_TMP}/delta.tar.gz"
sudo install -m 755 "${DELTA_TMP}/delta" /usr/local/bin/delta
rm -rf "${DELTA_TMP}"

# Debian/Ubuntu ship fd as 'fdfind' (name clash with another package) - provide 'fd'.
echo "Linking fdfind to /usr/local/bin/fd ..."
sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
