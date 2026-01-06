#!/usr/bin/env bash

cd $(dirname $(readlink -f $0))

which nvim &> /dev/null
if [ "$?" != "0" ]; then
  echo "nvim is not installed. Please install nvim."
  exit 1
fi

echo "nvim is installed creating new configuration..."

rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim &> /dev/null
cp -vr home/.config/nvim ~/.config/nvim
nvim --headless "+Lazy! sync" +qa

