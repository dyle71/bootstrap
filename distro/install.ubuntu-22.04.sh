#!/bin/sh
# Install packages for Ubuntu 22.04 LTS (Jammy)
# Note: eza is not in the default Ubuntu 22.04 repos and requires an external source.
set -e

PACKAGES="git net-tools iproute2 zsh curl wget gpg"

echo "Updating package lists..."
sudo apt-get update -q

echo "Installing base packages..."
sudo apt-get install -y ${PACKAGES}

echo "Installing neovim from GitHub releases (apt only provides 0.6)..."
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

# eza is not in Ubuntu 22.04 main repos - add official eza repository
echo "Adding eza repository..."
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt-get update -q
sudo apt-get install -y eza
