#!/bin/sh
# Deploy the user systemd units shipped with this bootstrap repository into
# ~/.config/systemd/user/ and enable them, mirroring the reference machine.
#
# Every unit that carries an [Install] section is enabled (rclone mounts,
# OneDrive sync, timers). enable-linger lets those units keep running without
# an active login session.
#
# When called from install.sh the bootstrap directory is passed as $1.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

# systemd is optional (Alpine/Gentoo may run OpenRC) - skip cleanly if absent.
if ! command -v systemctl > /dev/null 2>&1; then
    echo "systemd not detected (no systemctl) - skipping systemd setup."
    exit 0
fi

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }
TARGET_USER="${USER:-$(id -un)}"
USER_SRC="${BOOTSTRAP_DIR}/home/.config/systemd/user"
USER_DST="${HOME}/.config/systemd/user"

[ -d "${USER_SRC}" ] || { echo "No user units to install."; exit 0; }

echo "Installing user units into ${USER_DST} ..."
mkdir -p "${USER_DST}"
for src in "${USER_SRC}"/*.service "${USER_SRC}"/*.timer; do
    [ -e "${src}" ] || continue
    cp -v "${src}" "${USER_DST}/"
done

# A running user systemd session is required to enable units. In a piped
# "curl | sh" run it may be missing - copy the files and bail out gracefully.
if ! systemctl --user show-environment > /dev/null 2>&1; then
    echo "No user systemd session available - files copied only."
    echo "Enable later with: systemctl --user enable --now <unit>"
    exit 0
fi

systemctl --user daemon-reload

# Keep user units running without an active login session.
loginctl enable-linger "${TARGET_USER}" 2>/dev/null || true

# Enable every unit that carries an [Install] section - this mirrors the set
# enabled on the reference machine (rclone mounts, OneDrive sync, timers).
# Oneshot services triggered by a timer have no [Install] and are pulled in by
# their timer. A unit whose backing tool (e.g. rclone) is not configured yet
# will fail to *start*; that is reported but does not abort the setup.
for src in "${USER_SRC}"/*.service "${USER_SRC}"/*.timer; do
    [ -e "${src}" ] || continue
    grep -q '^\[Install\]' "${src}" || continue
    name=$(basename "${src}")
    echo "Enabling ${name} ..."
    systemctl --user enable --now "${name}" || \
        echo "WARNING: could not enable ${name}" >&2
done

echo ""
echo "systemd setup complete."
