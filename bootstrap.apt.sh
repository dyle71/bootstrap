#!/bin/bash

if [[ "$(basename ${0})" != "bootstrap.apt.sh" ]]; then
    echo "Invoke this script as a shell script do not 'source' this script."
    exit 1
fi
cd $(dirname $(readlink -f $0))

ESSENTIAL_APPS="vim git"
NICE_APPS="vim git tmux bash-completion net-tools iproute2 exa batcat zsh"

echo "Nice apps to install:"
echo "    sudo apt-get install -y ${NICE_APPS}"

for APP in ${ESSENTIAL_APPS}; do
    which ${APP} > /dev/null
    if [[ $? != 0 ]]; then
        echo "At least one of the nice apps (${ESSENTIAL_APPS}) is missing."
        echo "Run a: "
        echo "    sudo apt-get -y install ${ESSENTIAL_APPS}"
        exit 1
    fi
done

if [[ ! -d /usr/share/bash-completion ]]; then 
    echo "bash-completion not installed."
    echo "Run a: "
    echo "    sudo apt-get -y install ${NICE_APPS}"
    echo "to pull in some nice packages."
    exit 1
fi

if [[ -z "${HOME}" ]]; then
    echo "HOME not set. Huh! o.O"
    echo "Cannot proceed..."
    exit 1
fi

cp -v home/.bashrc.dyle ${HOME}
cp -v home/.zshrc.dyle ${HOME}
cp -v home/.p10k.zsh ${HOME}
cp -v home/.gitconfig ${HOME}
cp -v home/.vimrc ${HOME}
mkdir ${HOME}/.vim &> /dev/null
cp -rv home/.vim/* ${HOME}/.vim/
grep -q 'test -f ~/.bashrc.dyle && . ~/.bashrc.dyle' ~/.bashrc || echo 'test -f ~/.bashrc.dyle && . ~/.bashrc.dyle' >> ~/.bashrc
grep -q 'test -f ~/.zshrc.dyle && . ~/.zshrc.dyle' ~/.zshrc || echo 'test -f ~/.zshrc.dyle && . ~/.zshrc.dyle' >> ~/.zshrc
