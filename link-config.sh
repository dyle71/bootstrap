#!/usr/bin/env bash

cd $(dirname $(readlink -f $0))

mkdir -p ${HOME}/.config &> /dev/null
ln -sfv home/.zshrc ${HOME}
ln -sfv home/.zshrc.dyle ${HOME}
ln -sfv home/.p10k.zsh ${HOME}
ln -sfv home/.gitconfig ${HOME}
ln -sfv home/.config/nvim ${HOME}/.config/nvim
ln -sfv home/.config/bat ${HOME}/.config/bat
