# bootstrap

Bootstrap my ideal Linux shell environment in one command.

## Quick install

Server side (any machine, headless included):

```sh
curl https://raw.githubusercontent.com/dyle71/bootstrap/main/install.sh | sh
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
curl https://raw.githubusercontent.com/dyle71/bootstrap/main/install-de.sh | sh
```

This will:

1. Install the Qt/KDE integration packages (Breeze Dark for Dolphin & co.) and the dark GTK theme
2. Install the user fonts (JetBrainsMono NF Fixed for prompt and terminal)
3. Install the COSMIC desktop settings (panel, dock, theme, terminal, ...)
4. Install the Qt/KDE theme settings (Breeze Dark for KDE apps under COSMIC)
5. Install the GTK theme settings (dark theme for GTK and Electron apps, e.g. the VS Code menu bar)
6. Install the helper scripts into `~/Applications`
7. Install and enable the desktop systemd user units (`laptop-primary-monitor`)
8. Remove the temporary clone

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

`neovim  git  net-tools  eza  difftastic  iproute2  zsh  curl  wget`
`fd  ripgrep  ncdu  jq`

`jq` is required by the Claude Code status line (`statusline-command.sh`).

On Debian/Ubuntu fd is packaged as `fd-find` with the binary `fdfind`; the
distro script links it to `/usr/local/bin/fd`.

`install-de.sh` additionally installs (Qt/KDE theme integration, names vary per distro):

`breeze  qt6-wayland  qt6ct`

and the dark GTK theme where packaged (`adw-gtk-theme` on Arch, `adw-gtk3-theme`
on Fedora/RHEL; elsewhere `setup-gtk.sh` falls back to GTK3's built-in `Adwaita-dark`).

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
setup-applications.sh # Copy helper scripts to ~/Applications, seed ~/.config/sync-onedrive/config.toml (never overwrites)
setup-systemd.sh    # Install and enable systemd user units (mode: server | desktop)
setup-claude.sh     # Copy Claude Code settings, status line and mods to ~/.claude
setup-fonts.sh      # Copy user fonts to ~/.local/share/fonts and refresh the font cache
setup-cosmic.sh     # Copy COSMIC desktop settings to ~/.config/cosmic
setup-gtk.sh        # GTK theme: adw-gtk3-dark (or Adwaita-dark) in gsettings and ~/.config/gtk-{3,4}.0/settings.ini
setup-qt.sh         # Qt/KDE theme: QT_QPA_PLATFORMTHEME=qt6ct (environment.d + ~/.zprofile), kdeglobals, per-app Breeze Dark, qt6ct (Breeze Dark palette enforced)
home/               # Dotfiles and config files
  .zshrc
  .zshrc.dyle
  .p10k.zsh
  .gitconfig
  Applications/     # Helper scripts (sync-onedrive, laptop-primary-monitor.sh, git-repo-setup-*, ...)
  .claude/          # Claude Code CLAUDE.md, settings.json, statusline-command.sh, mods/
  .config/
    nvim/           # NvChad-based neovim config
    bat/
    sync-onedrive/  # config.toml for ~/Applications/sync-onedrive (seeded only if absent)
    cosmic/         # COSMIC desktop settings (panel, dock, theme, compositor, ...)
    environment.d/  # qt-theme.conf: QT_QPA_PLATFORMTHEME=qt6ct for the desktop session
    kdeglobals      # KDE colors (Breeze Dark), widget style, icons, fonts
    qt6ct/          # qt6ct fallback config (COSMIC writes its own at login)
    systemd/
      user/         # systemd user units (services and timers)
  .local/
    share/
      applications/ # Dock launchers (launch-*.desktop), Nextcloud entry without QT_QPA_PLATFORMTHEME
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
  keeps the internal laptop panel enabled and Xwayland-primary and mirrors it when an external
  monitor is plugged in (see below)

Units that need rclone remotes configured will fail to *start* until that
config exists; the mounts and syncs depend on the `OneDrive HTL Villach:`,
`Teams - IT-Management:` and `Teams - Lehrer IF MT:` rclone remotes.

```sh
systemctl --user list-timers                       # inspect scheduled timers
journalctl --user -u onedrive-sync.service -n 50   # inspect a unit's log
```

## COSMIC desktop settings

Part of `install-de.sh`. `home/.config/cosmic/` is a copy of `~/.config/cosmic/` from the reference
machine (one RON file per setting). `setup-cosmic.sh` copies it over the
target's tree, so shipped keys are overwritten and everything else stays. It
is skipped when COSMIC is not installed. To refresh the repo from the machine:

```sh
rm -rf home/.config/cosmic && cp -a ~/.config/cosmic home/.config/
```

The COSMIC terminal is set to the `JetBrainsMono NF Fixed` font, which
`setup-fonts.sh` installs from `home/.local/share/fonts/` (`install-de.sh`
runs it before `setup-cosmic.sh`).

### No focus stealing (COSMIC)

By default an app that requests activation (e.g. Telegram on a new message)
gets the focus, and COSMIC switches to its workspace. The compositor key
`com.system76.CosmicComp/v1/activation_policy` is set to `Urgent`: windows
never take the focus themselves and are only marked urgent. This applies to
all apps (a link clicked in another app does not raise the browser either).
Other values: `Focus` (default), `FocusIfActiveWorkspace`. COSMIC Settings has
no UI for this key.

### Laptop panel stays on and primary (COSMIC)

Wayland has no global "primary monitor". COSMIC remembers a layout per monitor
combination in `~/.local/state/cosmic-comp/outputs.ron` (runtime state, not
shipped here) and only knows *Xwayland primary* for X11 apps. Panel and dock are
shown on all outputs (`output` = `All`).

`~/Applications/laptop-primary-monitor.sh` uses `cosmic-randr` to enable the
internal panel (`eDP-1`/`eDP-2`, auto-detected) and make it the Xwayland primary.
It never enables the panel while the lid is closed. By default it also mirrors
the internal panel on every external output (COSMIC itself defaults to extend
for unknown monitors). Opt out with `echo extend > ~/.config/monitor-mode`;
remove the file to mirror again. `laptop-primary-monitor.service` runs it with
`--watch` after every hotplug.

```sh
journalctl --user -u laptop-primary-monitor.service -f   # watch it react to hotplugs
```

### Nextcloud tray icon (COSMIC)

With a Qt platform theme (`QT_QPA_PLATFORMTHEME=qt6ct`) that sets the
breeze-dark icon theme, Nextcloud only passes the icon name `state-ok` to the
tray (no pixmap). The COSMIC panel looks that name up in its own icon theme
(Cosmic, Pop, hicolor), where it does not exist, so the tray icon shows up
broken. Without the platform theme
Nextcloud sends the icon as a pixmap, which COSMIC displays correctly.
Nextcloud is therefore started with `env -u QT_QPA_PLATFORMTHEME`:
`setup-cosmic.sh` installs an override of its desktop entry into
`~/.local/share/applications/` (launcher and dock), and `setup-qt.sh` prefixes
the `Exec=` line of `~/.config/autostart/Nextcloud.desktop` if Nextcloud has
created it. Nextcloud rewrites that file when "Launch on system startup" is
toggled, so re-run `setup-qt.sh` afterwards. systemd generates
`app-Nextcloud@autostart.service` from the autostart entry at login;
`setup-qt.sh` runs `systemctl --user daemon-reload` so the change applies
without logging out. Other tray apps are not affected.

## Claude Code

`setup-claude.sh` copies `home/.claude/` to `~/.claude/`:

- `CLAUDE.md`: global rules. Reports stay terse; changes to the system
  (packages, services, configuration, dotfiles, `~/.config`, `~/.claude`, files
  outside the current project) are shown as command or diff and need explicit
  confirmation. Source, tests and docs of the current project are edited
  directly. No commit, merge or push without explicit OK.
- `settings.json`: permissions. `ask` for git writes (commit, merge, push,
  rebase, reset), `sudo`, `rm`, `pacman`, `yay` and `systemctl`. `deny` reads of
  `~/.ssh`, `~/.aws`, `.env` files, `~/.claude/.credentials.json` and session
  transcripts (`~/.claude/projects/*/*.jsonl`); project memory under
  `~/.claude/projects/` stays readable.
- `statusline-command.sh` and `mods/`: status line and context-bar mod.

The live `~/.claude/` is the source of truth: change settings there, then copy
them back into this repository.

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
sh setup-gtk.sh                  # install GTK theme settings
sh setup-systemd.sh . desktop    # install desktop systemd user units
```

---

Oliver Maurhart  
dyle71@gmail.com
