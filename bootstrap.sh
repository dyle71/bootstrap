#!/bin/bash

NICE_APPS="vim git screen"
NICE_INSTALL="vim git screen bash-completion"
for app in ${NICE_APPS}; do
    which ${app} > /dev/null
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
    echo
    echo "sudo apt-get -y install ${NICE_INSTALL}"
    exit 1
fi
        
cp -rv home/.bashrc.dyle ~
cat home/.bashrc >> ~/.bashrc
cp -rv home/.gitconfig ~
cp -rv home/.screenrc ~
cp -rv home/.vimrc ~
mkdir ~/.vim &> /dev/null
cp -rv home/.vim/* ~/.vim/
cp -rv home/.vimrc ~
mkdir ~/.ssh &> /dev/null
chmod 700 ~/.ssh
cp -rv home/.ssh/* ~/.ssh/


function install_or_update_vim_bundle() {

    if [[ -z ${1} ]]; then
        echo "No git url given."
        exit 1
    fi

    if [[ -z ${2} ]]; then
        echo "No bundle name given."
        exit 1
    fi

    mkdir -p "~/.vim/bundle" &> /dev/null
    BUNDLE_PATH="~/.vim/bundle/${2}"
    if [[ -d ${BUNDLE_PATH} ]]; then
        ( cd ${BUNDLE_PATH} && git pull -v );
    else
        git clone ${1} ${BUNDLE_PATH}
    fi
}

install_or_update_vim_bundle https://github.com/vim-scripts/ctrlp.vim.git ctrlp.vim
install_or_update_vim_bundle https://github.com/vim-scripts/The-NERD-tree.git The-NERD-tree
install_or_update_vim_bundle https://github.com/vim-airline/vim-airline.git vim-airline
install_or_update_vim_bundle https://github.com/vim-airline/vim-airline-themes.git vim-airline-themes
install_or_update_vim_bundle https://github.com/airblade/vim-gitgutter.git vim-gitgutter
install_or_update_vim_bundle https://github.com/VundleVim/Vundle.vim.git Vundle.vim

