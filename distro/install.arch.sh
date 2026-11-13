#!/bin/sh
# Install packages for Arch Linux
set -e

PACKAGES="neovim git net-tools eza git-delta iproute2 zsh curl wget"

echo "Updating package databases..."
sudo pacman -Sy --noconfirm

echo "Installing: ${PACKAGES}"
sudo pacman -S --noconfirm ${PACKAGES}

# Qt/KDE theme integration for KDE programs (Dolphin & co.) outside of Plasma,
# see setup-qt.sh. Only on desktop machines; installed one by one so a package
# missing in this release does not abort the bootstrap.
QT_PACKAGES="plasma-integration breeze qt6-wayland qt6ct"
if [ -n "${XDG_CURRENT_DESKTOP:-}" ] \
    || command -v cosmic-comp > /dev/null 2>&1 \
    || command -v plasmashell > /dev/null 2>&1; then
    for pkg in ${QT_PACKAGES}; do
        echo "Installing: ${pkg}"
        sudo pacman -S --noconfirm --needed "${pkg}" \
            || echo "WARNING: ${pkg} is not available here; Qt programs may not use Breeze Dark."
    done
fi
