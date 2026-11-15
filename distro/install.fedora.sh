#!/bin/sh
# Install packages for Fedora
# Note: iproute2 is called 'iproute' in Fedora/RPM-based distros.
set -e

PACKAGES="neovim git net-tools eza git-delta iproute zsh curl wget fd-find ripgrep ncdu"

echo "Installing: ${PACKAGES}"
sudo dnf install -y ${PACKAGES}
