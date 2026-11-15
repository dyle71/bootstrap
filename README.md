# bootstrap

Bootstrap my ideal Linux shell environment in one command.

## Quick install

Server side (any machine, headless included):

```sh
curl https://gitlab.com/dyle71/bootstrap/-/raw/main/install.sh | sh
```

This will:

1. Detect your OS and version
2. Install all required packages
3. Set up zsh with Powerlevel10k
4. Set up neovim with NvChad
5. Install the helper scripts into `~/Applications`
6. Install and enable the server systemd user units (rclone mounts, OneDrive sync, timers)
7. Set up Claude Code
8. Remove the temporary clone

After the script finishes, log out and back in (or run `exec zsh`).

Desktop environment (X11/Wayland), additionally on desktops and laptops:

```sh
curl https://gitlab.com/dyle71/bootstrap/-/raw/main/install-de.sh | sh
```

This will:

1. Install the Qt/KDE integration packages (Breeze Dark for Dolphin & co.)
2. Install the user fonts (JetBrainsMono NF Fixed for prompt and terminal)
3. Install the COSMIC desktop settings (panel, dock, theme, terminal, ...)
4. Install the Qt/KDE theme settings (Breeze Dark for KDE apps under COSMIC)
5. Install and enable the desktop systemd user units (`laptop-primary-monitor`)
6. Remove the temporary clone

Log out and back in afterwards.

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

`neovim  git  net-tools  eza  git-delta  iproute2  zsh  curl  wget`

`install-de.sh` additionally installs (Qt/KDE theme integration, names vary per distro):

`plasma-integration  breeze  qt6-wayland  qt6ct`

## Repository layout

```text
install.sh          # Entry point for curl | sh (server side)
install-de.sh       # Entry point for curl | sh (desktop environment)
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
setup-systemd.sh    # Install and enable systemd user units (mode: server | desktop)
setup-claude.sh     # Copy Claude Code settings, status line and mods to ~/.claude
setup-fonts.sh      # Copy user fonts to ~/.local/share/fonts and refresh the font cache
setup-cosmic.sh     # Copy COSMIC desktop settings to ~/.config/cosmic
setup-qt.sh         # Qt/KDE theme: QT_QPA_PLATFORMTHEME=kde, kdeglobals, qt6ct
home/               # Dotfiles and config files
  .zshrc
  .zshrc.dyle
  .p10k.zsh
  .gitconfig
  .claude/          # Claude Code settings.json, statusline-command.sh, mods/
  .config/
    nvim/           # NvChad-based neovim config
    bat/
    cosmic/         # COSMIC desktop settings (panel, dock, theme, compositor, ...)
    environment.d/  # qt-theme.conf: QT_QPA_PLATFORMTHEME=kde for the desktop session
    kdeglobals      # KDE colors (Breeze Dark), widget style, icons, fonts
    qt6ct/          # qt6ct config and Breeze Dark color scheme
    systemd/
      user/         # systemd user units (services and timers)
  .local/
    share/
      fonts/        # JetBrainsMono NF Fixed (Nerd Font used by p10k and COSMIC terminal)
```

## systemd user units

The `.service` and `.timer` files under `home/.config/systemd/user/` are
copied to `~/.config/systemd/user/` by `setup-systemd.sh`, which then enables
every unit that has an `[Install]` section. Units with
`WantedBy=graphical-session.target` are desktop units and are only installed
by `install-de.sh` (`setup-systemd.sh <dir> desktop`); all others are server
units, installed by `install.sh` (`setup-systemd.sh <dir> server`), which also
runs `loginctl enable-linger` so they keep working without an active login
session. These mirror the units running on the reference machine:

- `htl-teams-it-management.service`, `htl-teams-lehrer-if-mt.service` — rclone mounts of the HTL Teams document libraries
- `onedrive-sync.service` — continuous OneDrive bisync (via `~/Applications/sync-onedrive`)
- `onedrive-periodic.service` + `.timer` — periodic bisync fallback
- `rclone-token-refresh.service` + `.timer` — daily `rclone lsd` to keep the OAuth tokens fresh
- `agentlytics.service` + `.timer` — daily agentlytics collect job
- `laptop-primary-monitor.service` (desktop) — COSMIC only: watches DRM hotplug events and
  keeps the internal laptop panel enabled and Xwayland-primary when an external
  monitor is plugged in (see below)

Units that need rclone remotes configured will fail to *start* until that
config exists; the mounts and syncs depend on the `OneDrive HTL Villach:`,
`Teams - IT-Management:` and `Teams - Lehrer IF MT:` rclone remotes.

```sh
systemctl --user list-timers                       # inspect scheduled timers
journalctl --user -u onedrive-sync.service -n 50   # inspect a unit's log
```

## COSMIC desktop settings

`home/.config/cosmic/` is a copy of `~/.config/cosmic/` from the reference
machine (one RON file per setting). `setup-cosmic.sh` copies it over the
target's tree, so shipped keys are overwritten and everything else stays. It
is skipped when COSMIC is not installed. To refresh the repo from the machine:

```sh
rm -rf home/.config/cosmic && cp -a ~/.config/cosmic home/.config/
```

The COSMIC terminal is set to the `JetBrainsMono NF Fixed` font, which
`setup-fonts.sh` installs from `home/.local/share/fonts/` (run before
`setup-cosmic.sh`).

### Laptop panel stays on and primary (COSMIC)

Wayland has no global "primary monitor". COSMIC remembers a layout per monitor
combination in `~/.local/state/cosmic-comp/outputs.ron` (runtime state, not
shipped here) and only knows *Xwayland primary* for X11 apps. Panel and dock are
shown on all outputs (`output` = `All`).

`~/Applications/laptop-primary-monitor.sh` uses `cosmic-randr` to enable the
internal panel (`eDP-1`/`eDP-2`, auto-detected) and make it the Xwayland primary.
It never enables the panel while the lid is closed. `laptop-primary-monitor.service`
runs it with `--watch` after every hotplug.

```sh
journalctl --user -u laptop-primary-monitor.service -f   # watch it react to hotplugs
```

## Running steps individually

```sh
# After a fresh clone:
sh distro/install.debian-12.sh   # install packages
sh setup-zsh.sh                  # configure zsh
sh setup-nvim.sh                 # configure neovim
sh setup-applications.sh         # install helper scripts into ~/Applications
sh setup-systemd.sh . server     # install server systemd user units
sh setup-claude.sh               # install Claude Code configuration

# Desktop environment:
sh setup-fonts.sh                # install user fonts
sh setup-cosmic.sh               # install COSMIC desktop settings
sh setup-qt.sh                   # install Qt/KDE theme settings
sh setup-systemd.sh . desktop    # install desktop systemd user units
```

---

Oliver Maurhart  
dyle71@gmail.com
