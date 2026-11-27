#!/bin/sh
# Install the "Oxygen 13 Green Emerald" mouse cursor theme and make it the
# cursor of the desktop session (COSMIC compositor, Xwayland, GTK, Qt/KDE).
#
# There is no single cursor setting under COSMIC; every toolkit looks in its
# own place, so the theme name is written to all of them:
#
#   ~/.icons/Oxygen 13 Green Emerald/
#       The theme itself, shipped in home/.icons/ (not packaged by the
#       distributions). Replaced as a whole on every run. The original theme
#       only has the legacy X11 names (left_ptr, xterm, ...); cosmic-comp asks
#       for the CSS names of the cursor-shape protocol ("default", "ew-resize",
#       ...), so the shipped copy adds symlinks for them and Inherits=Adwaita
#       for anything still missing. Without "default" COSMIC falls back to
#       its own arrow while e.g. the "text" cursor already is Oxygen.
#   ~/.icons/default/index.theme
#       Inherits=<theme>. Fallback for programs that load the cursor theme
#       "default" when XCURSOR_THEME is unset (cosmic-comp, libXcursor).
#   ~/.config/environment.d/cursor.conf + ~/.zprofile
#       XCURSOR_THEME and XCURSOR_SIZE for the session. environment.d covers
#       the systemd user session; start-cosmic ignores it and runs "$SHELL -l",
#       so a block in ~/.zprofile exports cursor.conf in the login shell as
#       well (same approach as qt-theme.conf in setup-qt.sh). Added once.
#   ~/.config/gtk-{3,4}.0/settings.ini, gsettings org.gnome.desktop.interface
#       gtk-cursor-theme-name/-size and cursor-theme/cursor-size for GTK apps.
#   ~/.config/kcminputrc
#       [Mouse] cursorTheme/cursorSize for KDE apps. kde-gtk-config copies it
#       into the GTK settings and xsettingsd.conf, so a stale value here would
#       overwrite the GTK keys again.
#   ~/.config/xsettingsd/xsettingsd.conf
#       Gtk/CursorThemeName/Size for X11 GTK apps; only updated if it exists.
#
# Log out and back in afterwards: the compositor reads the cursor at startup.
#
# When called from install-de.sh the bootstrap directory is passed as $1.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }

THEME="Oxygen 13 Green Emerald"
SIZE=24

SRC="${BOOTSTRAP_DIR}/home/.icons/${THEME}"
ICONS="${HOME}/.icons"
CONFIG="${HOME}/.config"

[ -d "${SRC}" ] || { echo "ERROR: cursor theme not found: ${SRC}" >&2; exit 1; }

# set_key <file> <key> <value>: replace key=value or append it (single-section files).
set_key() {
    if grep -q "^$2=" "$1"; then
        sed -i "s|^$2=.*|$2=$3|" "$1"
    else
        echo "$2=$3" >> "$1"
    fi
}

# --- Theme files -----------------------------------------------------------
echo "Installing cursor theme into ${ICONS}/${THEME} ..."
mkdir -p "${ICONS}"
tmp="${ICONS}/.${THEME}.tmp.$$"
rm -rf "${tmp}"
cp -a "${SRC}" "${tmp}"
rm -rf "${ICONS:?}/${THEME}"
mv "${tmp}" "${ICONS}/${THEME}"

mkdir -p "${ICONS}/default"
printf '[Icon Theme]\nInherits=%s\n' "${THEME}" > "${ICONS}/default/index.theme"
echo "Updated ${ICONS}/default/index.theme"

# --- Session environment ---------------------------------------------------
echo "Installing cursor environment into ${CONFIG}/environment.d ..."
mkdir -p "${CONFIG}/environment.d"
cp -v "${BOOTSTRAP_DIR}/home/.config/environment.d/cursor.conf" "${CONFIG}/environment.d/"

ZPROFILE="${HOME}/.zprofile"
ZPROFILE_MARK="# bootstrap setup-cursor.sh: mouse cursor theme for the desktop session"
if ! grep -qF "${ZPROFILE_MARK}" "${ZPROFILE}" 2> /dev/null; then
    echo "Adding cursor theme export to ${ZPROFILE} ..."
    cat >> "${ZPROFILE}" <<'EOF'

# bootstrap setup-cursor.sh: mouse cursor theme for the desktop session
# start-cosmic ignores environment.d, so export it in the login shell too.
if [ -r "${HOME}/.config/environment.d/cursor.conf" ]; then
    set -a
    . "${HOME}/.config/environment.d/cursor.conf"
    set +a
fi
EOF
fi

# --- GTK -------------------------------------------------------------------
for ver in 3.0 4.0; do
    ini="${CONFIG}/gtk-${ver}/settings.ini"
    mkdir -p "$(dirname "${ini}")"
    [ -s "${ini}" ] || echo "[Settings]" > "${ini}"
    grep -q '^\[Settings\]' "${ini}" || sed -i '1i [Settings]' "${ini}"
    set_key "${ini}" gtk-cursor-theme-name "${THEME}"
    set_key "${ini}" gtk-cursor-theme-size "${SIZE}"
    echo "Updated ${ini}"
done

if command -v gsettings > /dev/null 2>&1 \
    && gsettings list-schemas 2>/dev/null | grep -qx org.gnome.desktop.interface; then
    gsettings set org.gnome.desktop.interface cursor-theme "${THEME}"
    gsettings set org.gnome.desktop.interface cursor-size "${SIZE}"
    echo "Updated gsettings org.gnome.desktop.interface"
else
    echo "gsettings or org.gnome.desktop.interface schema not available - skipped."
fi

XSETTINGSD="${CONFIG}/xsettingsd/xsettingsd.conf"
if [ -f "${XSETTINGSD}" ]; then
    sed -i -e "s|^Gtk/CursorThemeName .*|Gtk/CursorThemeName \"${THEME}\"|" \
        -e "s|^Gtk/CursorThemeSize .*|Gtk/CursorThemeSize ${SIZE}|" "${XSETTINGSD}"
    echo "Updated ${XSETTINGSD}"
fi

# --- Qt/KDE ----------------------------------------------------------------
KCMINPUTRC="${CONFIG}/kcminputrc"
if command -v kwriteconfig6 > /dev/null 2>&1; then
    kwriteconfig6 --file "${KCMINPUTRC}" --group Mouse --key cursorTheme "${THEME}"
    kwriteconfig6 --file "${KCMINPUTRC}" --group Mouse --key cursorSize "${SIZE}"
else
    [ -f "${KCMINPUTRC}" ] || : > "${KCMINPUTRC}"
    grep -q '^\[Mouse\]' "${KCMINPUTRC}" || printf '[Mouse]\n' >> "${KCMINPUTRC}"
    for kv in "cursorTheme=${THEME}" "cursorSize=${SIZE}"; do
        key="${kv%%=*}"
        if sed -n '/^\[Mouse\]/,/^\[/p' "${KCMINPUTRC}" | grep -q "^${key}="; then
            sed -i "/^\[Mouse\]/,/^\[/ s|^${key}=.*|${kv}|" "${KCMINPUTRC}"
        else
            sed -i "/^\[Mouse\]/a ${kv}" "${KCMINPUTRC}"
        fi
    done
fi
echo "Updated ${KCMINPUTRC}"

echo ""
echo "Cursor setup complete."
echo "Log out and back in to use ${THEME} everywhere."
