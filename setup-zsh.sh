#!/bin/sh
# Setup zsh with znap and Powerlevel10k configuration.
# When called from install.sh the bootstrap directory is passed as $1.
# Files are copied (not symlinked) so the bootstrap dir can be removed afterwards.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }
command -v zsh > /dev/null 2>&1 || { echo "ERROR: zsh is not installed" >&2; exit 1; }

# Install znap
ZNAP_REPOS="${HOME}/.znap-repos"
rm -rf "${ZNAP_REPOS}" 2>/dev/null || true
mkdir -p "${ZNAP_REPOS}"
echo "Cloning znap..."
git clone --depth=1 https://github.com/marlonrichert/zsh-snap.git "${ZNAP_REPOS}/znap"

# Copy config files
echo "Copying zsh configuration..."
cp -v "${BOOTSTRAP_DIR}/home/.zshrc"      "${HOME}/.zshrc"
cp -v "${BOOTSTRAP_DIR}/home/.zshrc.dyle" "${HOME}/.zshrc.dyle"
cp -v "${BOOTSTRAP_DIR}/home/.p10k.zsh"   "${HOME}/.p10k.zsh"

# Copy bat config
mkdir -p "${HOME}/.config/bat"
cp -v "${BOOTSTRAP_DIR}/home/.config/bat/config" "${HOME}/.config/bat/config"

# Copy .gitconfig only if none exists yet
if [ ! -f "${HOME}/.gitconfig" ]; then
    cp -v "${BOOTSTRAP_DIR}/home/.gitconfig" "${HOME}/.gitconfig"
fi

# Change default shell to zsh
ZSH_PATH=$(command -v zsh)
CURRENT_SHELL=$(getent passwd "${USER}" | cut -d: -f7 2>/dev/null || true)
if [ -n "${ZSH_PATH}" ] && [ "${CURRENT_SHELL}" != "${ZSH_PATH}" ]; then
    echo "Changing default shell to zsh..."
    sudo chsh -s "${ZSH_PATH}" "${USER}"
fi

echo ""
echo "Zsh setup complete."
echo "Plugins (Powerlevel10k, completions, syntax-highlighting) will be installed"
echo "automatically on the first zsh launch."
