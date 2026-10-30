#!/bin/sh
# Install packages for Arch Linux
set -e

PACKAGES="neovim git net-tools eza git-delta iproute2 zsh curl wget"

echo "Updating package databases..."
sudo pacman -Sy --noconfirm

echo "Installing: ${PACKAGES}"
sudo pacman -S --noconfirm ${PACKAGES}
