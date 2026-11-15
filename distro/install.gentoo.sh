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
    sys-apps/fd
    sys-apps/ripgrep
    sys-fs/ncdu
"

echo "Syncing portage tree..."
sudo emerge --sync --quiet

echo "Installing packages..."
# shellcheck disable=SC2086
sudo emerge --quiet ${PACKAGES}
