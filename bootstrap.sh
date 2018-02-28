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
cp -rv home/.vim ~/.vim
cp -rv home/.vimrc ~
cp -rv home/.ssh ~/.ssh

git clone https://github.com/vim-scripts/ctrlp.vim.git ~/.vim/bundle/ctrlp.vim
git clone https://github.com/vim-scripts/The-NERD-tree.git ~/.vim/bundle/The-NERD-tree
git clone https://github.com/vim-airline/vim-airline.git ~/.vim/bundle/vim-airline
git clone https://github.com/vim-airline/vim-airline-themes.git ~/.vim/bundle/vim-airline-themes
git clone https://github.com/airblade/vim-gitgutter.git ~/.vim/bundle/vim-gitgutter
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

