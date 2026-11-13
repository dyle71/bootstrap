#!/bin/sh
# Install packages for openSUSE (Tumbleweed and Leap)
set -e

PACKAGES="neovim git net-tools eza iproute2 zsh curl wget"

echo "Refreshing repositories..."
sudo zypper --non-interactive refresh

echo "Installing: ${PACKAGES}"
sudo zypper --non-interactive install ${PACKAGES}

# git-delta is not packaged for every Leap release; the rest of the setup works without it.
echo "Installing: git-delta"
sudo zypper --non-interactive install git-delta \
    || echo "WARNING: git-delta is not available here; 'pager = delta' in .gitconfig needs it."

# Qt/KDE theme integration for KDE programs (Dolphin & co.) outside of Plasma,
# see setup-qt.sh. Only on desktop machines; installed one by one so a package
# missing in this release does not abort the bootstrap.
QT_PACKAGES="plasma6-integration-plugin breeze6-style qt6-wayland qt6ct"
if [ -n "${XDG_CURRENT_DESKTOP:-}" ] \
    || command -v cosmic-comp > /dev/null 2>&1 \
    || command -v plasmashell > /dev/null 2>&1; then
    for pkg in ${QT_PACKAGES}; do
        echo "Installing: ${pkg}"
        sudo zypper --non-interactive install "${pkg}" \
            || echo "WARNING: ${pkg} is not available here; Qt programs may not use Breeze Dark."
    done
fi
