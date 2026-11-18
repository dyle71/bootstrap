#!/bin/sh
# Desktop environment (X11/Wayland) installer for dyle's Linux environment.
#
# Run this on desktop/laptop machines in addition to install.sh, which only
# sets up the server side (shell, editor, tools, systemd user units).
#
# Usage (one-liner, no local clone needed):
#   curl https://raw.githubusercontent.com/dyle71/bootstrap/main/install-de.sh | sh
#
# What this script does:
#   1. Detects the OS
#   2. Installs git if absent (needed to clone this repo)
#   3. Clones this repository (depth 1) into a temporary directory
#   4. Installs the Qt/KDE integration packages (Breeze Dark for Dolphin & co.)
#   5. Installs the user fonts (~/.local/share/fonts)
#   6. Installs the COSMIC desktop settings (~/.config/cosmic)
#   7. Installs the Qt/KDE theme settings
#   8. Installs the helper scripts into ~/Applications
#      (needed by the desktop units, e.g. laptop-primary-monitor.sh)
#   9. Installs and enables the desktop systemd user units
#      (WantedBy=graphical-session.target, e.g. laptop-primary-monitor)
#  10. Removes the temporary clone
set -e

REPO_URL="https://github.com/dyle71/bootstrap.git"

error() {
    echo "ERROR: $*" >&2
    exit 1
}

# ---------------------------------------------------------------------------
# OS detection and package manager
# ---------------------------------------------------------------------------

[ -f /etc/os-release ] || error "/etc/os-release not found - cannot detect OS."
. /etc/os-release
echo "Detected OS: ${PRETTY_NAME:-${ID} ${VERSION_ID}}"

if [ "$(id -u)" = "0" ]; then SUDO=""; else SUDO="sudo"; fi

# Qt/KDE theme integration for KDE programs (Dolphin & co.) outside of Plasma,
# see setup-qt.sh. Package names differ per distribution.
case "${ID}" in
    debian|ubuntu|linuxmint|pop)
        PKG_UPDATE="${SUDO} apt-get update -q"
        PKG_INSTALL="${SUDO} apt-get install -y"
        QT_PACKAGES="breeze qt6-wayland qt6ct"
        ;;
    arch)
        PKG_UPDATE="${SUDO} pacman -Sy --noconfirm"
        PKG_INSTALL="${SUDO} pacman -S --noconfirm --needed"
        QT_PACKAGES="breeze qt6-wayland qt6ct"
        ;;
    alpine)
        PKG_UPDATE="${SUDO} apk update"
        PKG_INSTALL="${SUDO} apk add --no-cache"
        QT_PACKAGES="breeze qt6-qtwayland qt6ct"
        ;;
    fedora|rhel)
        PKG_UPDATE="true"
        PKG_INSTALL="${SUDO} dnf install -y"
        QT_PACKAGES="plasma-breeze qt6-qtwayland qt6ct"
        ;;
    gentoo)
        PKG_UPDATE="true"
        PKG_INSTALL="${SUDO} emerge --quiet --noreplace"
        QT_PACKAGES="kde-plasma/breeze dev-qt/qtwayland x11-misc/qt6ct"
        ;;
    opensuse-tumbleweed|opensuse-leap|opensuse)
        PKG_UPDATE="${SUDO} zypper --non-interactive refresh"
        PKG_INSTALL="${SUDO} zypper --non-interactive install"
        QT_PACKAGES="breeze6-style qt6-wayland qt6ct"
        ;;
    *)
        error "Unsupported OS: ${ID}"
        ;;
esac

# ---------------------------------------------------------------------------
# Bootstrap git and clone the repository
# ---------------------------------------------------------------------------

if ! command -v git > /dev/null 2>&1; then
    echo "git not found - installing..."
    ${PKG_UPDATE}
    ${PKG_INSTALL} git
fi

WORK_DIR=$(mktemp -d /tmp/bootstrap.XXXXXX)
cleanup() {
    echo "Removing temporary directory ${WORK_DIR}..."
    rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

echo "Cloning bootstrap repository..."
git clone --depth 1 "${REPO_URL}" "${WORK_DIR}"

# ---------------------------------------------------------------------------
# Run steps
# ---------------------------------------------------------------------------

echo ""
echo "=== Step 1/6: Installing Qt/KDE integration packages ==="
${PKG_UPDATE}
# One by one, so a package missing in this release does not abort the setup.
for pkg in ${QT_PACKAGES}; do
    echo "Installing: ${pkg}"
    ${PKG_INSTALL} "${pkg}" \
        || echo "WARNING: ${pkg} is not available here; Qt programs may not use Breeze Dark."
done

echo ""
echo "=== Step 2/6: Installing fonts ==="
sh "${WORK_DIR}/setup-fonts.sh" "${WORK_DIR}"

echo ""
echo "=== Step 3/6: Setting up COSMIC desktop ==="
sh "${WORK_DIR}/setup-cosmic.sh" "${WORK_DIR}"

echo ""
echo "=== Step 4/6: Setting up Qt/KDE theme ==="
sh "${WORK_DIR}/setup-qt.sh" "${WORK_DIR}"

echo ""
echo "=== Step 5/6: Installing helper scripts ==="
sh "${WORK_DIR}/setup-applications.sh" "${WORK_DIR}"

echo ""
echo "=== Step 6/6: Setting up desktop systemd user units ==="
sh "${WORK_DIR}/setup-systemd.sh" "${WORK_DIR}" desktop

echo ""
echo "========================================"
echo " Desktop setup complete!"
echo " Please log out and back in."
echo "========================================"
