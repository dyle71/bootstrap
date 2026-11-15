#!/bin/sh
# Install the user fonts shipped in this repo into ~/.local/share/fonts.
#
# Currently this is "JetBrainsMono NF Fixed", a Nerd Font variant of
# JetBrains Mono. It provides the glyphs for the Powerlevel10k prompt
# (nerdfont-v3) and is the font configured for the COSMIC terminal.
#
# When called from install-de.sh the bootstrap directory is passed as $1.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }

SRC="${BOOTSTRAP_DIR}/home/.local/share/fonts"
DST="${HOME}/.local/share/fonts"

[ -d "${SRC}" ] || { echo "No fonts to install."; exit 0; }

echo "Copying fonts into ${DST} ..."
mkdir -p "${DST}"
# Running programs (e.g. cosmic-term) mmap the font files. Overwriting a
# font in place truncates the mapped file and kills them with SIGBUS, so
# unchanged fonts are skipped and changed ones are replaced atomically
# (copy to a temp file, then rename: mapped readers keep the old inode).
(cd "${SRC}" && find . -type f) | while IFS= read -r f; do
    src="${SRC}/${f#./}"
    dst="${DST}/${f#./}"
    if [ -f "${dst}" ] && cmp -s "${src}" "${dst}"; then
        continue
    fi
    mkdir -p "$(dirname "${dst}")"
    cp "${src}" "${dst}.tmp.$$"
    mv -f "${dst}.tmp.$$" "${dst}"
    echo "installed: ${dst}"
done

if command -v fc-cache > /dev/null 2>&1; then
    echo "Refreshing font cache..."
    fc-cache -f "${DST}"
else
    echo "fc-cache not found - font cache not refreshed."
fi

echo ""
echo "Font setup complete."
