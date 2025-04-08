#!/usr/bin/env bash

if [[ "$(basename ${0})" != "bootstrap.sh" ]]; then
  echo "Invoke this script as a shell script do not 'source' this script."
  exit 1
fi
cd $(dirname $(readlink -f $0))

[[ -f /etc/os-release ]] && . /etc/os-release
OS_DIST_NAME=${ID}

APPS_TO_INSTALL=""
if [[ "${OS_DIST_NAME}" == "arch" ]]; then
  APPS_TO_INSTALL="neovim git net-tools eza iproute2 bat zsh curl wget"
elif [[ "${OS_DIST_NAME}" == "ubuntu" ]]; then
  APPS_TO_INSTALL="neovim git net-tools exa iproute2 bat zsh curl wget"
elif [[ "${OS_DIST_NAME}" == "debian" ]]; then
  APPS_TO_INSTALL="neovim git net-tools exa iproute2 bat zsh curl wget"
else
  echo "Unsupported OS distribution: ${OS_DIST_NAME}"
  exit 1
fi

IS_APT_GET=$(command -v apt-get)
IS_PACMAN=$(command -v pacman)
if [[ -z "${IS_APT_GET}" && -z "${IS_PACMAN}" ]]; then
  echo "Neither apt-get nor pacman found. Cannot proceed..."
  exit 1
fi

if [[ -n "${IS_APT_GET}" ]]; then
  echo "sudo apt-get install -y ${APPS_TO_INSTALL}"
  sudo apt-get install -y ${APPS_TO_INSTALL}
fi
if [[ -n "${IS_PACMAN}" ]]; then
  echo "sudo pacman -S --noconfirm ${APPS_TO_INSTALL}"
  sudo pacman -S ${APPS_TO_INSTALL}
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
