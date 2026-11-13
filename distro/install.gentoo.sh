#!/bin/sh
# Install packages for Gentoo Linux
set -e

PACKAGES="
    app-editors/neovim
    dev-vcs/git
    sys-apps/net-tools
    sys-apps/eza
    dev-util/git-delta
    sys-apps/iproute2
    app-shells/zsh
    net-misc/curl
    net-misc/wget
"

echo "Syncing portage tree..."
sudo emerge --sync --quiet

echo "Installing packages..."
# shellcheck disable=SC2086
sudo emerge --quiet ${PACKAGES}

# Qt/KDE theme integration for KDE programs (Dolphin & co.) outside of Plasma,
# see setup-qt.sh. Only on desktop machines; installed one by one so a package
# missing in this release does not abort the bootstrap.
QT_PACKAGES="kde-plasma/plasma-integration kde-plasma/breeze dev-qt/qtwayland x11-misc/qt6ct"
if [ -n "${XDG_CURRENT_DESKTOP:-}" ] \
    || command -v cosmic-comp > /dev/null 2>&1 \
    || command -v plasmashell > /dev/null 2>&1; then
    for pkg in ${QT_PACKAGES}; do
        echo "Installing: ${pkg}"
        sudo emerge --quiet --noreplace "${pkg}" \
            || echo "WARNING: ${pkg} is not available here; Qt programs may not use Breeze Dark."
    done
fi
