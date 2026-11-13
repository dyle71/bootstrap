#!/bin/sh
# Install packages for Alpine Linux
set -e

PACKAGES="neovim git net-tools eza delta iproute2 zsh curl wget"

# Use sudo if not root
if [ "$(id -u)" = "0" ]; then
    APK="apk"
else
    APK="sudo apk"
fi

echo "Updating package index..."
${APK} update

echo "Installing: ${PACKAGES}"
${APK} add --no-cache ${PACKAGES}

# Qt/KDE theme integration for KDE programs (Dolphin & co.) outside of Plasma,
# see setup-qt.sh. Only on desktop machines; installed one by one so a package
# missing in this release does not abort the bootstrap.
QT_PACKAGES="plasma-integration breeze qt6-qtwayland qt6ct"
if [ -n "${XDG_CURRENT_DESKTOP:-}" ] \
    || command -v cosmic-comp > /dev/null 2>&1 \
    || command -v plasmashell > /dev/null 2>&1; then
    for pkg in ${QT_PACKAGES}; do
        echo "Installing: ${pkg}"
        ${APK} add --no-cache "${pkg}" \
            || echo "WARNING: ${pkg} is not available here; Qt programs may not use Breeze Dark."
    done
fi
