#!/bin/sh
# Deploy the helper scripts in home/Applications/ into ~/Applications/ and seed
# the sync-onedrive configuration.
#
# The systemd units start ~/Applications/sync-onedrive, so the binary must live
# there before setup-systemd.sh enables them. Config files that carry personal
# data (remotes, local paths) are seeded only when absent, so re-running this
# script never clobbers local edits.
#
# When called from install.sh the bootstrap directory is passed as $1.
# Files are copied (not symlinked) so the bootstrap dir can be removed afterwards.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }

APPS_SRC="${BOOTSTRAP_DIR}/home/Applications"
APPS_DST="${HOME}/Applications"

# ── Helper scripts ──────────────────────────────────────────────────────────
if [ -d "${APPS_SRC}" ]; then
    echo "Installing helper scripts into ${APPS_DST} ..."
    mkdir -p "${APPS_DST}"
    for src in "${APPS_SRC}"/*; do
        [ -f "${src}" ] || continue   # skip __pycache__ and other directories
        dst="${APPS_DST}/$(basename "${src}")"
        cp -v "${src}" "${dst}"
        chmod +x "${dst}"
    done
else
    echo "No helper scripts to install (${APPS_SRC} missing)."
fi

# ── sync-onedrive configuration (seed only, never overwrite) ────────────────
CFG_SRC="${BOOTSTRAP_DIR}/home/.config/sync-onedrive/config.toml"
CFG_DST="${HOME}/.config/sync-onedrive/config.toml"

if [ -f "${CFG_SRC}" ]; then
    if [ -f "${CFG_DST}" ]; then
        echo "Keeping existing ${CFG_DST} (not overwritten)."
    else
        echo "Seeding sync-onedrive config into ${CFG_DST} ..."
        mkdir -p "$(dirname "${CFG_DST}")"
        cp -v "${CFG_SRC}" "${CFG_DST}"
        echo "  Edit it to match your rclone remotes (see: rclone listremotes)."
    fi
fi

echo ""
echo "Applications setup complete."
