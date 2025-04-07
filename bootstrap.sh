#!/usr/bin/env bash

if [[ "$(basename ${0})" != "bootstrap.sh" ]]; then
  echo "Invoke this script as a shell script do not 'source' this script."
  exit 1
fi
cd $(dirname $(readlink -f $0))

ARCH_APPS="neovim git net-tools eza iproute2 bat zsh curl wget"
DEB_APPS="neovim git net-tools exa iproute2 batcat zsh curl wget"

IS_APT_GET=$(command -v apt-get)
IS_PACMAN=$(command -v pacman)

if [[ -z "${IS_APT_GET}" && -z "${IS_PACMAN}" ]]; then
  echo "Neither apt-get nor pacman found. Cannot proceed..."
  exit 1
fi

if [[ -n "${IS_APT_GET}" ]]; then
  echo "sudo apt-get install -y ${DEB_APPS}"
  sudo apt-get install -y ${DEB_APPS}
fi
if [[ -n "${IS_PACMAN}" ]]; then
  echo "sudo pacman -S --noconfirm ${ARCH_APPS}"
  sudo pacman -S ${ARCH_APPS}
fi

if [[ -z "${HOME}" ]]; then
  echo "HOME environment variable not set. Cannot proceed..."
  exit 1
fi

export ZNAP_REPOS="${HOME}/.znap-repos"
rm -rf ${ZNAP_REPOS} &> /dev/null
mkdir -p ${ZNAP_REPOS}
echo "git clone --depth 1 -- https://github.com/marlonrichert/zsh-snap.git ${ZNAP_REPOS}/znap"
git clone --depth=1 https://github.com/marlonrichert/zsh-snap.git ${ZNAP_REPOS}/znap

./link-config.sh

zsh -i -c "source ~/.
