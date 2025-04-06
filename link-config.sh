#!/usr/bin/env bash

INSTALL_PATH=$(dirname $(readlink -f $0))

cd ${HOME}
mkdir -p ${HOME}/.config &> /dev/null

ln -sfv ${INSTALL_PATH}/home/.zshrc ${HOME}/.zshrc
ln -sfv ${INSTALL_PATH}/home/.zshrc.dyle ${HOME}/.zshrc.dyle
ln -sfv ${INSTALL_PATH}/home/.p10k.zsh ${HOME}/.p10k.zsh
ln -sfv ${INSTALL_PATH}/home/.gitconfig ${HOME}/.gitconfig
ln -sfv ${INSTALL_PATH}/home/.config/nvim ${HOME}/.config/nvim
ln -sfv ${INSTALL_PATH}/home/.config/bat ${HOME}/.config/bat
