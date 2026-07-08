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
5. Install the systemd user units and enable the agentlytics timer
6. Remove the temporary clone

After the script finishes, log out and back in (or run `exec zsh`).

## Supported systems

| Distribution | Version             |
|--------------|---------------------|
| Debian       | 12, 13              |
| Ubuntu       | 22.04, 24.04, 26.04 |
| Arch Linux   | current             |
| Alpine Linux | current             |
| Fedora       | current             |
| RHEL         | 9, 10               |
| Gentoo       | current             |
| openSUSE     | Tumbleweed, Leap    |
| Linux Mint   | 21.x, 22.x          |
| Pop!\_OS     | 22.04, 24.04        |

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
  install.ubuntu-26.04.sh
  install.arch.sh
  install.alpine.sh
  install.fedora.sh
  install.rhel.sh
  install.gentoo.sh
  install.opensuse.sh
setup-zsh.sh        # Install znap, Powerlevel10k and copy dotfiles
setup-nvim.sh       # Copy NvChad config and run initial plugin sync
setup-systemd.sh    # Install systemd user units and enable the agentlytics timer
home/               # Dotfiles and config files
  .zshrc
  .zshrc.dyle
  .p10k.zsh
  .gitconfig
  .config/
    nvim/           # NvChad-based neovim config
    bat/
    systemd/
      user/         # systemd user units (services and timers)
```

## systemd user units

The `.service` and `.timer` files under `home/.config/systemd/user/` are
copied to `~/.config/systemd/user/` by `setup-systemd.sh`. Only the
`agentlytics.timer` (a daily collect job) is enabled automatically, together
with `loginctl enable-linger` so the timers run without an active login
session. Enable any of the other units yourself with:

```sh
systemctl --user enable --now <unit>   # e.g. onedrive-download.timer
systemctl --user list-timers           # inspect scheduled timers
```

## Running steps individually

```sh
# After a fresh clone:
sh distro/install.debian-12.sh   # install packages
sh setup-zsh.sh                  # configure zsh
sh setup-nvim.sh                 # configure neovim
sh setup-systemd.sh              # install systemd user units
```

---

Oliver Maurhart  
dyle71@gmail.com
