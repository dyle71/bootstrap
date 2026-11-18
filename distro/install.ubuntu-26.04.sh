#!/bin/sh
# Install packages for Ubuntu 26.04 LTS (Questing)
set -e

PACKAGES="neovim git net-tools eza iproute2 zsh curl wget fd-find ripgrep ncdu jq"

echo "Updating package lists..."
sudo apt-get update -q

echo "Installing: ${PACKAGES}"
sudo apt-get install -y ${PACKAGES}

echo "Installing difftastic from GitHub releases (not packaged in apt)..."
DIFFT_VERSION=$(basename "$(curl -Ls --fail -o /dev/null -w '%{url_effective}' "https://github.com/Wilfred/difftastic/releases/latest")")
DIFFT_TMP=$(mktemp -d)
curl -L --fail "https://github.com/Wilfred/difftastic/releases/download/${DIFFT_VERSION}/difft-${DIFFT_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
    -o "${DIFFT_TMP}/difft.tar.gz"
tar -C "${DIFFT_TMP}" -xzf "${DIFFT_TMP}/difft.tar.gz"
sudo install -m 755 "${DIFFT_TMP}/difft" /usr/local/bin/difft
rm -rf "${DIFFT_TMP}"

# Debian/Ubuntu ship fd as 'fdfind' (name clash with another package) - provide 'fd'.
echo "Linking fdfind to /usr/local/bin/fd ..."
sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
