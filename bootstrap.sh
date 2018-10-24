#!/bin/bash

cd $(dirname $(readlink -f $0))

NICE_APPS="vim git"
NICE_INSTALL="vim git screen tmux bash-completion net-tools powerline"

for APP in ${NICE_APPS}; do
    which ${APP} > /dev/null
    if [[ $? != 0 ]]; then
        echo "At least one of the nice apps (${NICE_APPS}) is missing."
        echo "Run a: "
        echo
        echo "sudo apt-get -y install ${NICE_INSTALL}"
        exit 1
    fi
done

if [[ ! -d /usr/share/bash-completion ]]; then 
    echo "bash-completion not installed."
    echo "Run a: "
    echo "      sudo apt-get -y install ${NICE_INSTALL}"
    echo "to pull in some nice packages."
    exit 1
fi

if [[ -z "${HOME}" ]]; then
    echo "HOME not set. Huh! o.O"
    echo "Cannot proceed..."
    exit 1
fi

cp -rv home/.bashrc.dyle ${HOME}
cat home/.bashrc >> ${HOME}/.bashrc
cp -rv home/.gitconfig ${HOME}
cp -rv home/.screenrc ${HOME}
cp -rv home/.vimrc ${HOME}
mkdir ${HOME}/.vim &> /dev/null
cp -rv home/.vim/* ${HOME}/.vim/
cp -rv home/.vimrc ${HOME}
mkdir ${HOME}/.ssh &> /dev/null &> /dev/null
chmod 700 ${HOME}/.ssh
cp -rv home/.ssh/* ${HOME}/.ssh/


function install_or_update_vim_bundle() {

    if [[ -z ${1} ]]; then
        echo "No git url given."
        exit 1
    fi

    if [[ -z ${2} ]]; then
        echo "No bundle name given."
        exit 1
    fi

    mkdir -p "${HOME}/.vim/bundle" &> /dev/null
    BUNDLE_PATH="${HOME}/.vim/bundle/${2}"
    if [[ -d ${BUNDLE_PATH} ]]; then
        ( cd ${BUNDLE_PATH} && git pull -v );
    else
        git clone --depth 1 ${1} ${BUNDLE_PATH}
    fi
}

install_or_update_vim_bundle https://github.com/vim-scripts/ctrlp.vim.git ctrlp.vim
install_or_update_vim_bundle https://github.com/vim-scripts/The-NERD-tree.git The-NERD-tree
install_or_update_vim_bundle https://github.com/vim-airline/vim-airline.git vim-airline
install_or_update_vim_bundle https://github.com/vim-airline/vim-airline-themes.git vim-airline-themes
install_or_update_vim_bundle https://github.com/airblade/vim-gitgutter.git vim-gitgutter
install_or_update_vim_bundle https://github.com/VundleVim/Vundle.vim.git Vundle.vim

