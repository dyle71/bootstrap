#!/bin/sh
# Install packages for Red Hat Enterprise Linux (RHEL 9/10)
# eza and neovim require EPEL (Extra Packages for Enterprise Linux).
# Note: iproute2 is called 'iproute' in RPM-based distros.
set -e

PACKAGES="neovim git net-tools eza iproute zsh curl wget"

echo "Enabling EPEL repository..."
sudo dnf install -y epel-release

echo "Installing: ${PACKAGES}"
sudo dnf install -y ${PACKAGES}
