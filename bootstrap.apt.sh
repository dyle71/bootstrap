#!/usr/bin/env bash

if [[ "$(basename ${0})" != "bootstrap.apt.sh" ]]; then
    echo "Invoke this script as a shell script do not 'source' this script."
    exit 1
fi
cd $(dirname $(readlink -f $0))

APPS="neovim git bash-completion net-tools iproute2 exa batcat zsh curl wget"
echo "sudo apt-get install -y ${APPS}"
sudo apt-get install -y ${APPS}

if [[ -z "${HOME}" ]]; then
    echo "HOME not set. Huh! o.O"
    echo "Cannot proceed..."
    exit 1
fi

echo "Install oh-my-zsh:"
echo 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'

echo "Install P10k zsh Theme:"
echo 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'

./link-config.sh
