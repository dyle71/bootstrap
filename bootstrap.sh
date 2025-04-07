#!/usr/bin/env bash

if [[ "$(basename ${0})" != "bootstrap.sh" ]]; then
    echo "Invoke this script as a shell script do not 'source' this script."
    exit 1
fi
cd $(dirname $(readlink -f $0))

APPS="neovim git net-tools eza iproute2 batcat zsh curl wget"

IS_APT_GET=$(command -v apt-get)
IS_PACMAN=$(command -v pacman)

if [[ -z "${IS_APT_GET}" && -z "${IS_PACMAN}" ]]; then
    echo "Neither apt-get nor pacman found. Cannot proceed..."
    exit 1
fi

if [[ -n "${IS_APT_GET}" ]]; then
    echo "sudo apt-get install -y ${APPS}"
    sudo apt-get install -y ${APPS}
fi
if [[ -n "${IS_PACMAN}" ]]; then
    echo "sudo pacman -S ${APPS}"
    sudo pacman -S ${APPS}
fi

echo "Install P10k zsh Theme:"
echo 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/local/src/powerlevel10k'
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/local/src/powerlevel10k

export ZNAP_REPOS="/usr/local/src/znap-repos"
[[ -r ${ZNAP_REPOS} ]] || git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ${ZNAP_REPOS}/znap

./link-config.sh
