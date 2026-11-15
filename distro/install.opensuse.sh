#!/bin/sh
# Install packages for openSUSE (Tumbleweed and Leap)
set -e

PACKAGES="neovim git net-tools eza iproute2 zsh curl wget fd ripgrep ncdu"

echo "Refreshing repositories..."
sudo zypper --non-interactive refresh

echo "Installing: ${PACKAGES}"
sudo zypper --non-interactive install ${PACKAGES}

# git-delta is not packaged for every Leap release; the rest of the setup works without it.
echo "Installing: git-delta"
sudo zypper --non-interactive install git-delta \
    || echo "WARNING: git-delta is not available here; 'pager = delta' in .gitconfig needs it."
