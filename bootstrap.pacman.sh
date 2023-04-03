#!/bin/bash

if [[ "$(basename ${0})" != "bootstrap.pacman.sh" ]]; then
    echo "Invoke this script as a shell script do not 'source' this script."
    exit 1
fi
cd $(dirname $(readlink -f $0))

ESSENTIAL_APPS="vim git"
NICE_APPS="vim git net-tools iproute2 exa bat zsh powerline zsh-theme-poerlevel10k"

echo "Nice apps to install:"
echo "    sudo pacman -S ${NICE_APPS}"

for APP in ${ESSENTIAL_APPS}; do
    which ${APP} > /dev/null
    if [[ $? != 0 ]]; then
        echo "At least one of the nice apps (${ESSENTIAL_APPS}) is missing."
        echo "Run a: "
        echo "    sudo pacman -S ${ESSENTIAL_APPS}"
        exit 1
    fi
done

if [[ ! -d /usr/share/bash-completion ]]; then 
    echo "bash-completion not installed."
    echo "Run a: "
    echo "    sudo pacman -S install ${NICE_APPS}"
    echo "to pull in some nice packages."
    exit 1
fi

if [[ -z "${HOME}" ]]; then
    echo "HOME not set. Huh! o.O"
    echo "Cannot proceed..."
    exit 1
fi

echo "Install oh-my-zsh:"
echo 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'

echo "Install P10k zsh Theme:"
echo 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'

cp -v home/.zshrc.dyle ${HOME}
cp -v home/.p10k.zsh ${HOME}
cp -v home/.gitconfig ${HOME}
cp -v home/.vimrc ${HOME}
mkdir ${HOME}/.vim &> /dev/null
cp -rv home/.vim/* ${HOME}/.vim/
grep -q 'test -f ~/.zshrc.dyle && . ~/.zshrc.dyle' ~/.zshrc || echo 'test -f ~/.zshrc.dyle && . ~/.zshrc.dyle' >> ~/.zshrc

