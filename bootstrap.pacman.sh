#!/usr/bin/env bash

if [[ "$(basename ${0})" != "bootstrap.pacman.sh" ]]; then
    echo "Invoke this script as a shell script do not 'source' this script."
    exit 1
fi
cd $(dirname $(readlink -f $0))

APPS="neovim git net-tools iproute2 exa bat zsh powerline zsh-theme-poerlevel10k curl wget"

echo "sudo pacman -S ${APPS}"
sudo pacman -S ${APPS}

if [[ -z "${HOME}" ]]; then
    echo "HOME not set. Huh! o.O"
    echo "Cannot proceed..."
    exit 1
fi

echo "Install P10k zsh Theme:"
echo 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/local/src/powerlevel10k'

./link-config.sh
