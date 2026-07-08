#!/bin/sh
# Bootstrap installer for dyle's Linux environment.
#
# Usage (one-liner, no local clone needed):
#   curl https://gitlab.com/dyle71/bootstrap/-/raw/main/install.sh | sh
#
# What this script does:
#   1. Detects the OS and version
#   2. Installs git if absent (needed to clone this repo)
#   3. Clones this repository (depth 1) into a temporary directory
#   4. Runs the distro-specific package install script
#   5. Sets up zsh with Powerlevel10k
#   6. Sets up neovim with NvChad
#   7. Installs and enables the systemd user units (mounts, OneDrive sync, timers)
#   8. Removes the temporary clone
set -e

REPO_URL="https://gitlab.com/dyle71/bootstrap.git"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

error() {
    echo "ERROR: $*" >&2
    exit 1
}

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------

[ -f /etc/os-release ] || error "/etc/os-release not found - cannot detect OS."
. /etc/os-release
echo "Detected OS: ${PRETTY_NAME:-${ID} ${VERSION_ID}}"

# ---------------------------------------------------------------------------
# Bootstrap git
# ---------------------------------------------------------------------------

if ! command -v git > /dev/null 2>&1; then
    echo "git not found - installing..."
    case "${ID}" in
        debian|ubuntu|linuxmint|pop)
            sudo apt-get update -q
            sudo apt-get install -y git
            ;;
        arch)
            sudo pacman -Sy --noconfirm git
            ;;
        alpine)
            if [ "$(id -u)" = "0" ]; then
                apk add --no-cache git
            else
                sudo apk add --no-cache git
            fi
            ;;
        fedora|rhel)
            sudo dnf install -y git
            ;;
        gentoo)
            sudo emerge --quiet dev-vcs/git
            ;;
        opensuse-tumbleweed|opensuse-leap|opensuse)
            sudo zypper --non-interactive install git
            ;;
        *)
            error "Cannot install git on unsupported OS '${ID}'."
            ;;
    esac
fi

# ---------------------------------------------------------------------------
# Clone bootstrap repository
# ---------------------------------------------------------------------------

WORK_DIR=$(mktemp -d /tmp/bootstrap.XXXXXX)
cleanup() {
    echo "Removing temporary directory ${WORK_DIR}..."
    rm -rf "${WORK_DIR}"
}
trap cleanup EXIT

echo "Cloning bootstrap repository..."
git clone --depth 1 "${REPO_URL}" "${WORK_DIR}"

# ---------------------------------------------------------------------------
# Select distro-specific install script
# ---------------------------------------------------------------------------

case "${ID}" in
    debian)
        case "${VERSION_ID}" in
            12) DISTRO_SCRIPT="${WORK_DIR}/distro/install.debian-12.sh" ;;
            13) DISTRO_SCRIPT="${WORK_DIR}/distro/install.debian-13.sh" ;;
            *)  error "Unsupported Debian version: ${VERSION_ID}" ;;
        esac
        ;;
    ubuntu)
        case "${VERSION_ID}" in
            22.04) DISTRO_SCRIPT="${WORK_DIR}/distro/install.ubuntu-22.04.sh" ;;
            24.04) DISTRO_SCRIPT="${WORK_DIR}/distro/install.ubuntu-24.04.sh" ;;
            26.04) DISTRO_SCRIPT="${WORK_DIR}/distro/install.ubuntu-26.04.sh" ;;
            *)     error "Unsupported Ubuntu version: ${VERSION_ID}" ;;
        esac
        ;;
    linuxmint)
        # Linux Mint 21.x is based on Ubuntu 22.04; 22.x on Ubuntu 24.04
        case "${VERSION_ID}" in
            21*) DISTRO_SCRIPT="${WORK_DIR}/distro/install.ubuntu-22.04.sh" ;;
            22*) DISTRO_SCRIPT="${WORK_DIR}/distro/install.ubuntu-24.04.sh" ;;
            *)   error "Unsupported Linux Mint version: ${VERSION_ID}" ;;
        esac
        ;;
    pop)
        # Pop!_OS version IDs mirror Ubuntu (22.04, 24.04, ...)
        case "${VERSION_ID}" in
            22.04) DISTRO_SCRIPT="${WORK_DIR}/distro/install.ubuntu-22.04.sh" ;;
            24.04) DISTRO_SCRIPT="${WORK_DIR}/distro/install.ubuntu-24.04.sh" ;;
            *)     error "Unsupported Pop!_OS version: ${VERSION_ID}" ;;
        esac
        ;;
    arch)
        DISTRO_SCRIPT="${WORK_DIR}/distro/install.arch.sh"
        ;;
    alpine)
        DISTRO_SCRIPT="${WORK_DIR}/distro/install.alpine.sh"
        ;;
    fedora)
        DISTRO_SCRIPT="${WORK_DIR}/distro/install.fedora.sh"
        ;;
    rhel)
        DISTRO_SCRIPT="${WORK_DIR}/distro/install.rhel.sh"
        ;;
    gentoo)
        DISTRO_SCRIPT="${WORK_DIR}/distro/install.gentoo.sh"
        ;;
    opensuse-tumbleweed|opensuse-leap|opensuse)
        DISTRO_SCRIPT="${WORK_DIR}/distro/install.opensuse.sh"
        ;;
    *)
        error "Unsupported OS: ${ID}"
        ;;
esac

# ---------------------------------------------------------------------------
# Run steps
# ---------------------------------------------------------------------------

echo ""
echo "=== Step 1/4: Installing packages for ${ID} ${VERSION_ID:-} ==="
sh "${DISTRO_SCRIPT}"

echo ""
echo "=== Step 2/4: Setting up zsh ==="
sh "${WORK_DIR}/setup-zsh.sh" "${WORK_DIR}"

echo ""
echo "=== Step 3/4: Setting up neovim ==="
sh "${WORK_DIR}/setup-nvim.sh" "${WORK_DIR}"

echo ""
echo "=== Step 4/4: Setting up systemd user units ==="
sh "${WORK_DIR}/setup-systemd.sh" "${WORK_DIR}"

echo ""
echo "========================================"
echo " Bootstrap complete!"
echo " Please log out and back in, or run:"
echo "   exec zsh"
echo "========================================"
