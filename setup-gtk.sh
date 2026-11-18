#!/bin/sh
# Set a dark GTK theme for GTK3/GTK4 programs and Electron apps (VS Code & co.).
#
# COSMIC's dark mode switch only sets the color-scheme preference and themes
# libadwaita via ~/.config/gtk-4.0/gtk.css; it never touches the GTK theme
# name. If that name points to a light or missing theme (e.g. "Breeze" written
# by kde-gtk-config without breeze-gtk installed), GTK3 falls back to the light
# Adwaita and Electron apps with a native title bar show a light menu bar.
#
# This script sets the theme name in the GNOME interface schema (gsettings) and
# in ~/.config/gtk-{3,4}.0/settings.ini. Only gtk-theme-name and
# gtk-application-prefer-dark-theme are changed; all other keys stay as they
# are. Uses adw-gtk3-dark if installed (package adw-gtk-theme, see
# install-de.sh), otherwise the Adwaita-dark theme built into GTK3.
#
# When called from install-de.sh the bootstrap directory is passed as $1
# (unused, accepted for consistency with the other setup scripts).
set -e

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }

THEME="Adwaita-dark"
for dir in "${HOME}/.local/share/themes" "${HOME}/.themes" /usr/local/share/themes /usr/share/themes; do
    if [ -d "${dir}/adw-gtk3-dark" ]; then
        THEME="adw-gtk3-dark"
        break
    fi
done
echo "Using GTK theme: ${THEME}"

# set_key <file> <key> <value>: replace the key in [Settings] or append it.
set_key() {
    if grep -q "^$2=" "$1"; then
        sed -i "s|^$2=.*|$2=$3|" "$1"
    else
        echo "$2=$3" >> "$1"
    fi
}

for ver in 3.0 4.0; do
    ini="${HOME}/.config/gtk-${ver}/settings.ini"
    mkdir -p "$(dirname "${ini}")"
    [ -s "${ini}" ] || echo "[Settings]" > "${ini}"
    grep -q '^\[Settings\]' "${ini}" || sed -i '1i [Settings]' "${ini}"
    set_key "${ini}" gtk-theme-name "${THEME}"
    set_key "${ini}" gtk-application-prefer-dark-theme true
    echo "Updated ${ini}"
done

if command -v gsettings > /dev/null 2>&1 \
    && gsettings list-schemas 2>/dev/null | grep -qx org.gnome.desktop.interface; then
    gsettings set org.gnome.desktop.interface gtk-theme "${THEME}"
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    echo "Updated gsettings org.gnome.desktop.interface"
else
    echo "gsettings or org.gnome.desktop.interface schema not available - skipped."
fi

echo ""
echo "GTK setup complete."
echo "Restart running GTK/Electron programs to pick up the theme."
