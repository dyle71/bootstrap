#!/bin/sh
# Install packages for Alpine Linux
set -e

PACKAGES="neovim git net-tools eza difftastic iproute2 zsh curl wget fd ripgrep ncdu jq"

# Use sudo if not root
if [ "$(id -u)" = "0" ]; then
    APK="apk"
else
    APK="sudo apk"
fi

echo "Updating package index..."
${APK} update

echo "Installing: ${PACKAGES}"
${APK} add --no-cache ${PACKAGES}
