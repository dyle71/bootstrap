# bootstrap

Bootstrap my ideal Linux shell environment in one command.

## Quick install

```sh
curl https://gitlab.com/dyle71/bootstrap/-/raw/main/install.sh | sh
```

This will:

1. Detect your OS and version
2. Install all required packages
3. Set up zsh with Powerlevel10k
4. Set up neovim with NvChad
5. Remove the temporary clone

After the script finishes, log out and back in (or run `exec zsh`).

## Supported systems

| Distribution | Version             |
|--------------|---------------------|
| Debian       | 12, 13              |
| Ubuntu       | 22.04, 24.04, 26.04 |
| Arch Linux   | current             |
| Alpine Linux | current             |

## Installed packages

`neovim  git  net-tools  eza  iproute2  zsh  curl  wget`

## Repository layout

```text
install.sh          # Entry point for curl | sh
distro/
  install.debian-12.sh
  install.debian-13.sh
  install.ubuntu-22.04.sh
  install.ubuntu-24.04.sh
  install.arch.sh
  install.alpine.sh
setup-zsh.sh        # Install znap, Powerlevel10k and copy dotfiles
setup-nvim.sh       # Copy NvChad config and run initial plugin sync
home/               # Dotfiles and config files
  .zshrc
  .zshrc.dyle
  .p10k.zsh
  .gitconfig
  .config/
    nvim/           # NvChad-based neovim config
    bat/
```

## Running steps individually

```sh
# After a fresh clone:
sh distro/install.debian-12.sh   # install packages
sh setup-zsh.sh                  # configure zsh
sh setup-nvim.sh                 # configure neovim
```

---

Oliver Maurhart  
dyle71@gmail.com
