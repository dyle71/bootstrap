#!/bin/sh
# Install packages for Red Hat Enterprise Linux (RHEL 9/10)
# eza, git-delta, neovim, fd-find, ripgrep and ncdu require EPEL (Extra Packages for Enterprise Linux).
# Note: iproute2 is called 'iproute' in RPM-based distros.
set -e

PACKAGES="neovim git net-tools eza git-delta iproute zsh curl wget fd-find ripgrep ncdu"

echo "Enabling EPEL repository..."
sudo dnf install -y epel-release

echo "Installing: ${PACKAGES}"
sudo dnf install -y ${PACKAGES}
