#!/bin/sh
# Setup neovim with NvChad configuration.
# When called from install.sh the bootstrap directory is passed as $1.
# Files are copied (not symlinked) so the bootstrap dir can be removed afterwards.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

command -v nvim > /dev/null 2>&1 || { echo "ERROR: neovim is not installed" >&2; exit 1; }

echo "Setting up neovim configuration..."
rm -rf "${HOME}/.config/nvim" "${HOME}/.local/share/nvim" "${HOME}/.local/state/nvim" 2>/dev/null || true

mkdir -p "${HOME}/.config"
cp -rv "${BOOTSTRAP_DIR}/home/.config/nvim" "${HOME}/.config/nvim"

echo "Running initial plugin sync (this may take a moment)..."
nvim --headless "+Lazy! sync" +qa

echo "Neovim setup complete."
