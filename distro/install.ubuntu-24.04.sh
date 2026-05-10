#!/bin/sh
# Install packages for Ubuntu 24.04 LTS (Noble)
set -e

PACKAGES="neovim git net-tools eza iproute2 zsh curl wget"

echo "Updating package lists..."
sudo apt-get update -q

echo "Installing: ${PACKAGES}"
sudo apt-get install -y ${PACKAGES}
