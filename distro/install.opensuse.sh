#!/bin/sh
# Install packages for openSUSE (Tumbleweed and Leap)
set -e

PACKAGES="neovim git net-tools eza iproute2 zsh curl wget fd ripgrep ncdu"

echo "Refreshing repositories..."
sudo zypper --non-interactive refresh

echo "Installing: ${PACKAGES}"
sudo zypper --non-interactive install ${PACKAGES}

# difftastic is only packaged for Tumbleweed; the rest of the setup works without it.
echo "Installing: difftastic"
sudo zypper --non-interactive install difftastic \
    || echo "WARNING: difftastic is not available here; 'diff.external = difft' in .gitconfig needs it."
