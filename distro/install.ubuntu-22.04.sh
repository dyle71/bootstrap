#!/bin/sh
# Install packages for Ubuntu 22.04 LTS (Jammy)
# Note: eza is not in the default Ubuntu 22.04 repos and requires an external source.
set -e

PACKAGES="neovim git net-tools iproute2 zsh curl wget gpg"

echo "Updating package lists..."
sudo apt-get update -q

echo "Installing base packages..."
sudo apt-get install -y ${PACKAGES}

# eza is not in Ubuntu 22.04 main repos - add official eza repository
echo "Adding eza repository..."
sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
    | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt-get update -q
sudo apt-get install -y eza
