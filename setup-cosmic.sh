#!/bin/sh
# Install the COSMIC desktop settings (panel, dock, theme, compositor,
# keyboard layout, wallpaper, applets, ...) into ~/.config/cosmic.
#
# COSMIC stores every setting as one small RON file per key under
# ~/.config/cosmic/<component>/v<N>/<key>. The files from the bootstrap repo
# are copied over the existing tree: keys shipped here are overwritten, all
# other keys on the target machine are left untouched. A running COSMIC
# session watches these files and applies the changes live.
#
# The custom launch-*.desktop files used as dock favorites (open a new window
# instead of focusing an existing one) are installed into
# ~/.local/share/applications.
#
# Skipped on machines without COSMIC (no cosmic-comp and no ~/.config/cosmic).
#
# When called from install-de.sh the bootstrap directory is passed as $1.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }

SRC="${BOOTSTRAP_DIR}/home/.config/cosmic"
DST="${HOME}/.config/cosmic"

[ -d "${SRC}" ] || { echo "No COSMIC settings to install."; exit 0; }

if ! command -v cosmic-comp > /dev/null 2>&1 && [ ! -d "${DST}" ]; then
    echo "COSMIC not detected - skipping COSMIC setup."
    exit 0
fi

echo "Copying COSMIC settings into ${DST} ..."
mkdir -p "${DST}"
cp -rv "${SRC}/." "${DST}/"

APPS_SRC="${BOOTSTRAP_DIR}/home/.local/share/applications"
APPS_DST="${HOME}/.local/share/applications"
if [ -d "${APPS_SRC}" ]; then
    echo "Copying dock launchers into ${APPS_DST} ..."
    mkdir -p "${APPS_DST}"
    cp -v "${APPS_SRC}"/*.desktop "${APPS_DST}/"
fi

echo ""
echo "COSMIC setup complete."
echo "A running COSMIC session picks up the changes live; otherwise log out and back in."
