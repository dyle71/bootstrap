#!/bin/sh
# Deploy the user systemd units shipped with this bootstrap repository into
# ~/.config/systemd/user/ and enable the agentlytics timer.
#
# systemd does not inherit your shell PATH, so the agentlytics service calls
# bunx via its absolute path (%h/.bun/bin/bunx). enable-linger lets the user
# units keep running without an active login session.
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
    echo "Enable later with: systemctl --user enable --now agentlytics.timer"
    exit 0
fi

systemctl --user daemon-reload

# Keep user timers running without an active login session.
loginctl enable-linger "${TARGET_USER}" 2>/dev/null || true

# Enable the agentlytics collect timer. The remaining user units (rclone
# mounts, OneDrive sync) are left for you to enable as needed.
if [ -e "${USER_SRC}/agentlytics.timer" ]; then
    echo "Enabling agentlytics.timer ..."
    systemctl --user enable --now agentlytics.timer || \
        echo "WARNING: could not enable agentlytics.timer" >&2
fi

echo ""
echo "systemd setup complete."
echo "Enable other user units as needed with:"
echo "  systemctl --user enable --now <unit>"
