#!/usr/bin/env bash

INSTALL_PATH=$(dirname $(readlink -f $0))

cd ${HOME}
mkdir -p ${HOME}/.config &> /dev/null
mkdir -p ${HOME}/.config/bat &> /dev/null
mkdir -p ${HOME}/.config/nvim &> /dev/null

ln -sfv ${INSTALL_PATH}/home/.zshrc ${HOME}/.zshrc
ln -sfv ${INSTALL_PATH}/home/.zshrc.dyle ${HOME}/.zshrc.dyle
ln -sfv ${INSTALL_PATH}/home/.p10k.zsh ${HOME}/.p10k.zsh
ln -sfv ${INSTALL_PATH}/home/.gitconfig ${HOME}/.gitconfig
ln -sfv ${INSTALL_PATH}/home/.config/bat/config ${HOME}/.config/bat/config
ln -sfv ${INSTALL_PATH}/home/.config/nvim/init.lua ${HOME}/.config/nvim/init.lua
