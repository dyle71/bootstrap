#!/bin/sh
# Install packages for openSUSE (Tumbleweed and Leap)
set -e

PACKAGES="neovim git net-tools eza iproute2 zsh curl wget"

echo "Refreshing repositories..."
sudo zypper --non-interactive refresh

echo "Installing: ${PACKAGES}"
sudo zypper --non-interactive install ${PACKAGES}
