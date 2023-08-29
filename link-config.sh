#!/usr/bin/env bash

cd $(dirname $(readlink -f $0))

mkdir -p ${HOME}/.config &> /dev/null
ln -sv home/.zshrc ${HOME}
ln -sv home/.zshrc.dyle ${HOME}
ln -sv home/.p10k.zsh ${HOME}
ln -sv home/.gitconfig ${HOME}
ln -sv home/.config/nvim ${HOME}/.config/nvim
