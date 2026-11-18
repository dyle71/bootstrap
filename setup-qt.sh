#!/bin/sh
# Install the Qt/KDE look & feel (Breeze Dark, breeze-dark icons, Noto Sans /
# Hack fonts) so KDE/Qt programs such as Dolphin look right outside of Plasma,
# e.g. when started from the COSMIC launcher or dock.
#
# The qt6ct platform theme is used instead of KDE's own (plasma-integration),
# because plasma-integration pulls in xdg-desktop-portal-kde and with it most
# of the Plasma workspace.
#
#   ~/.config/environment.d/qt-theme.conf
#       QT_QPA_PLATFORMTHEME=qt6ct for the systemd user session. Programs
#       started by the desktop (launcher, dock) inherit it, so Qt loads the
#       qt6ct platform theme which reads ~/.config/qt6ct/qt6ct.conf.
#   ~/.zprofile
#       COSMIC's start-cosmic does not use environment.d: it runs "$SHELL -l"
#       and, if QT_QPA_PLATFORMTHEME is still unset, sets it to cosmic/qt5ct
#       itself. A block in ~/.zprofile therefore exports qt-theme.conf in the
#       login shell before start-cosmic decides. Added once, existing content kept.
#   ~/.config/kdeglobals
#       Color scheme, widget style, icon theme and fonts. KDE programs read the
#       color scheme from here regardless of the platform theme. Only the theme
#       related groups are shipped; they are merged key by key with
#       kwriteconfig6, so other keys on the target machine are kept. Without
#       kwriteconfig6 the file is only copied if none exists yet.
#   ~/.config/{dolphinrc,katerc,okularrc,gwenviewrc,kmymoney/kmymoneyrc}
#       [UiSettings] ColorScheme=BreezeDark. Without the KDE platform theme
#       these programs pick a light window palette on their own but still draw
#       text and alternating rows from kdeglobals (white on light grey). An
#       explicit color scheme per program fixes that.
#   ~/.config/qt6ct/
#       Breeze style, breeze-dark icons, Breeze Dark palette and fonts for the
#       qt6ct platform theme. The full qt6ct.conf is only installed if none
#       exists yet, because COSMIC (cosmic-settings-daemon) may write its own.
#       An existing qt6ct.conf only gets the Breeze Dark palette enforced
#       (color_scheme_path, custom_palette=true): with custom_palette=false Qt
#       uses Breeze's light default palette together with the breeze-dark
#       icons, so e.g. LibreOffice (qt6 VCL plugin) shows white icons on light
#       toolbars. Re-run this script if COSMIC resets it.
#   ~/.config/autostart/Nextcloud.desktop
#       With a Qt platform theme that sets the breeze-dark icon theme Nextcloud
#       only passes the icon name "state-ok" to the tray (no pixmap). The
#       COSMIC panel looks it up in its own icon theme, which lacks it, so the
#       tray icon shows up broken. The Exec= line is prefixed with
#       "env -u QT_QPA_PLATFORMTHEME" so Nextcloud sends a pixmap instead.
#       Only touched if Nextcloud created the file; the launcher/dock entry is
#       overridden by setup-cosmic.sh. systemd turns the autostart entry into a
#       unit at login, so the user manager is reloaded to pick up the change
#       without logging out.
#
# Requires qt6ct and breeze to take effect.
# Skipped on machines without a desktop (no COSMIC, Plasma or Dolphin).
#
# When called from install-de.sh the bootstrap directory is passed as $1.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }

SRC="${BOOTSTRAP_DIR}/home/.config"
DST="${HOME}/.config"

if ! command -v cosmic-comp > /dev/null 2>&1 \
    && ! command -v plasmashell > /dev/null 2>&1 \
    && ! command -v dolphin > /dev/null 2>&1 \
    && [ ! -d "${DST}/cosmic" ]; then
    echo "No desktop detected - skipping Qt/KDE setup."
    exit 0
fi

# Merge an ini file into a KDE config file with kwriteconfig6.
# Group headers like [Colors:Header][Inactive] become nested --group options.
merge_kconfig() {
    src="$1"
    file="$2"
    groups=""
    while IFS= read -r line || [ -n "${line}" ]; do
        case "${line}" in
            ''|'#'*) continue ;;
            '['*)
                groups=$(printf '%s\n' "${line}" | sed 's/^\[//; s/\]$//; s/\]\[/\n/g')
                continue
                ;;
        esac
        key="${line%%=*}"
        value="${line#*=}"
        set --
        while IFS= read -r group; do
            set -- "$@" --group "${group}"
        done <<EOF
${groups}
EOF
        kwriteconfig6 --file "${file}" "$@" --key "${key}" -- "${value}"
    done < "${src}"
}

echo "Installing Qt platform theme environment into ${DST}/environment.d ..."
mkdir -p "${DST}/environment.d"
cp -v "${SRC}/environment.d/qt-theme.conf" "${DST}/environment.d/"

ZPROFILE="${HOME}/.zprofile"
ZPROFILE_MARK="# bootstrap setup-qt.sh: Qt platform theme for the desktop session"
if ! grep -qF "${ZPROFILE_MARK}" "${ZPROFILE}" 2> /dev/null; then
    echo "Adding Qt platform theme export to ${ZPROFILE} ..."
    cat >> "${ZPROFILE}" <<'EOF'

# bootstrap setup-qt.sh: Qt platform theme for the desktop session
# start-cosmic ignores environment.d and picks its own theme unless this is set.
if [ -r "${HOME}/.config/environment.d/qt-theme.conf" ]; then
    set -a
    . "${HOME}/.config/environment.d/qt-theme.conf"
    set +a
fi
EOF
fi

echo "Installing KDE theme settings into ${DST}/kdeglobals ..."
if command -v kwriteconfig6 > /dev/null 2>&1; then
    merge_kconfig "${SRC}/kdeglobals" "${DST}/kdeglobals"
    echo "kdeglobals merged."
elif [ ! -f "${DST}/kdeglobals" ]; then
    cp -v "${SRC}/kdeglobals" "${DST}/kdeglobals"
else
    echo "kwriteconfig6 not found and ${DST}/kdeglobals exists - left untouched."
fi

if command -v kwriteconfig6 > /dev/null 2>&1; then
    echo "Setting the Breeze Dark color scheme for KDE programs ..."
    for rc in dolphinrc katerc okularrc gwenviewrc kmymoney/kmymoneyrc; do
        mkdir -p "$(dirname "${DST}/${rc}")"
        kwriteconfig6 --file "${DST}/${rc}" --group UiSettings --key ColorScheme -- BreezeDark
    done
fi

if [ ! -f "${DST}/qt6ct/qt6ct.conf" ]; then
    echo "Installing qt6ct settings into ${DST}/qt6ct ..."
    mkdir -p "${DST}/qt6ct/colors"
    cp -v "${SRC}/qt6ct/colors/BreezeDark.conf" "${DST}/qt6ct/colors/"
    sed "s|/home/dyle/|${HOME}/|g" "${SRC}/qt6ct/qt6ct.conf" > "${DST}/qt6ct/qt6ct.conf"
else
    echo "Enforcing the Breeze Dark palette in ${DST}/qt6ct/qt6ct.conf ..."
    mkdir -p "${DST}/qt6ct/colors"
    cp -v "${SRC}/qt6ct/colors/BreezeDark.conf" "${DST}/qt6ct/colors/"
    set_qt6ct_appearance() {
        # Set key=value in the [Appearance] section, adding section/key if missing.
        awk -v key="$1" -v val="$2" '
            /^\[/ {
                if (in_sec && !done) { print key "=" val; done = 1 }
                in_sec = ($0 == "[Appearance]"); seen = seen || in_sec
            }
            in_sec && index($0, key "=") == 1 { print key "=" val; done = 1; next }
            { print }
            END {
                if (!seen) { print "[Appearance]" }
                if (!done) { print key "=" val }
            }' "${DST}/qt6ct/qt6ct.conf" > "${DST}/qt6ct/qt6ct.conf.tmp"
        mv "${DST}/qt6ct/qt6ct.conf.tmp" "${DST}/qt6ct/qt6ct.conf"
    }
    set_qt6ct_appearance color_scheme_path "${DST}/qt6ct/colors/BreezeDark.conf"
    set_qt6ct_appearance custom_palette true
fi

NEXTCLOUD_AUTOSTART="${DST}/autostart/Nextcloud.desktop"
if [ -f "${NEXTCLOUD_AUTOSTART}" ] \
    && ! grep -q '^Exec=env -u QT_QPA_PLATFORMTHEME ' "${NEXTCLOUD_AUTOSTART}"; then
    echo "Starting Nextcloud without QT_QPA_PLATFORMTHEME in ${NEXTCLOUD_AUTOSTART} ..."
    sed -i 's|^Exec=|Exec=env -u QT_QPA_PLATFORMTHEME |' "${NEXTCLOUD_AUTOSTART}"
    if systemctl --user daemon-reload 2> /dev/null; then
        echo "Restart Nextcloud (or log out and back in) to apply."
    fi
fi

echo ""
echo "Qt/KDE setup complete."
echo "Log out and back in so the desktop session picks up QT_QPA_PLATFORMTHEME."
