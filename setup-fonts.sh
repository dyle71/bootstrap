#!/bin/sh
# Install the user fonts shipped in this repo into ~/.local/share/fonts.
#
# Currently this is "JetBrainsMono NF Fixed", a Nerd Font variant of
# JetBrains Mono. It provides the glyphs for the Powerlevel10k prompt
# (nerdfont-v3) and is the font configured for the COSMIC terminal.
#
# When called from install.sh the bootstrap directory is passed as $1.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }

SRC="${BOOTSTRAP_DIR}/home/.local/share/fonts"
DST="${HOME}/.local/share/fonts"

[ -d "${SRC}" ] || { echo "No fonts to install."; exit 0; }

echo "Copying fonts into ${DST} ..."
mkdir -p "${DST}"
cp -rv "${SRC}/." "${DST}/"

if command -v fc-cache > /dev/null 2>&1; then
    echo "Refreshing font cache..."
    fc-cache -f "${DST}"
else
    echo "fc-cache not found - font cache not refreshed."
fi

echo ""
echo "Font setup complete."
