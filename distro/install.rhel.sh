#!/bin/sh
# Install packages for Red Hat Enterprise Linux (RHEL 9/10)
# eza, git-delta and neovim require EPEL (Extra Packages for Enterprise Linux).
# Note: iproute2 is called 'iproute' in RPM-based distros.
set -e

PACKAGES="neovim git net-tools eza git-delta iproute zsh curl wget"

echo "Enabling EPEL repository..."
sudo dnf install -y epel-release

echo "Installing: ${PACKAGES}"
sudo dnf install -y ${PACKAGES}

# Qt/KDE theme integration for KDE programs (Dolphin & co.) outside of Plasma,
# see setup-qt.sh. Only on desktop machines; installed one by one so a package
# missing in this release does not abort the bootstrap.
QT_PACKAGES="plasma-integration plasma-breeze qt6-qtwayland qt6ct"
if [ -n "${XDG_CURRENT_DESKTOP:-}" ] \
    || command -v cosmic-comp > /dev/null 2>&1 \
    || command -v plasmashell > /dev/null 2>&1; then
    for pkg in ${QT_PACKAGES}; do
        echo "Installing: ${pkg}"
        sudo dnf install -y "${pkg}" \
            || echo "WARNING: ${pkg} is not available here; Qt programs may not use Breeze Dark."
    done
fi
