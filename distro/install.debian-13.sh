#!/bin/sh
# Install packages for Debian 13 (Trixie)
set -e

PACKAGES="git net-tools eza git-delta iproute2 zsh curl wget"

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

# Qt/KDE theme integration for KDE programs (Dolphin & co.) outside of Plasma,
# see setup-qt.sh. Only on desktop machines; installed one by one so a package
# missing in this release does not abort the bootstrap.
QT_PACKAGES="plasma-integration breeze qt6-wayland qt6ct"
if [ -n "${XDG_CURRENT_DESKTOP:-}" ] \
    || command -v cosmic-comp > /dev/null 2>&1 \
    || command -v plasmashell > /dev/null 2>&1; then
    for pkg in ${QT_PACKAGES}; do
        echo "Installing: ${pkg}"
        sudo apt-get install -y "${pkg}" \
            || echo "WARNING: ${pkg} is not available here; Qt programs may not use Breeze Dark."
    done
fi
