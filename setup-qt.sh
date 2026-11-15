#!/bin/sh
# Install the Qt/KDE look & feel (Breeze Dark, breeze-dark icons, Noto Sans /
# Hack fonts) so KDE/Qt programs such as Dolphin look right outside of Plasma,
# e.g. when started from the COSMIC launcher or dock.
#
#   ~/.config/environment.d/qt-theme.conf
#       QT_QPA_PLATFORMTHEME=kde for the systemd user session. Programs started
#       by the desktop (launcher, dock) inherit it, so Qt loads the KDE platform
#       theme (plasma-integration) which reads ~/.config/kdeglobals.
#   ~/.config/kdeglobals
#       Color scheme, widget style, icon theme and fonts. Only the theme
#       related groups are shipped; they are merged key by key with
#       kwriteconfig6, so other keys on the target machine are kept. Without
#       kwriteconfig6 the file is only copied if none exists yet.
#   ~/.config/qt6ct/
#       Same look for the qt6ct platform theme (used if QT_QPA_PLATFORMTHEME
#       is switched to qt6ct).
#
# Requires plasma-integration (KDE platform theme) and breeze to take effect.
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

echo "Installing KDE theme settings into ${DST}/kdeglobals ..."
if command -v kwriteconfig6 > /dev/null 2>&1; then
    merge_kconfig "${SRC}/kdeglobals" "${DST}/kdeglobals"
    echo "kdeglobals merged."
elif [ ! -f "${DST}/kdeglobals" ]; then
    cp -v "${SRC}/kdeglobals" "${DST}/kdeglobals"
else
    echo "kwriteconfig6 not found and ${DST}/kdeglobals exists - left untouched."
fi

echo "Installing qt6ct settings into ${DST}/qt6ct ..."
mkdir -p "${DST}/qt6ct/colors"
cp -v "${SRC}/qt6ct/colors/BreezeDark.conf" "${DST}/qt6ct/colors/"
sed "s|/home/dyle/|${HOME}/|g" "${SRC}/qt6ct/qt6ct.conf" > "${DST}/qt6ct/qt6ct.conf"

echo ""
echo "Qt/KDE setup complete."
echo "Log out and back in so the desktop session picks up QT_QPA_PLATFORMTHEME."
