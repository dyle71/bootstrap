#!/bin/sh
# Setup Claude Code user configuration (~/.claude).
# When called from install.sh the bootstrap directory is passed as $1.
# Files are copied (not symlinked) so the bootstrap dir can be removed afterwards.
# Credentials, history and caches in ~/.claude are left untouched.
set -e

BOOTSTRAP_DIR="${1:-$(dirname "$(readlink -f "$0")")}"

[ -n "${HOME}" ] || { echo "ERROR: HOME not set" >&2; exit 1; }

echo "Copying Claude Code configuration..."
mkdir -p "${HOME}/.claude/mods"

# settings.json contains absolute paths - rewrite them for this user's home
sed "s|/home/dyle|${HOME}|g" "${BOOTSTRAP_DIR}/home/.claude/settings.json" > "${HOME}/.claude/settings.json"
echo "'${BOOTSTRAP_DIR}/home/.claude/settings.json' -> '${HOME}/.claude/settings.json'"

cp -v "${BOOTSTRAP_DIR}/home/.claude/statusline-command.sh" "${HOME}/.claude/statusline-command.sh"

rm -rf "${HOME}/.claude/mods/context-bar"
cp -rv "${BOOTSTRAP_DIR}/home/.claude/mods/context-bar" "${HOME}/.claude/mods/context-bar"

command -v jq > /dev/null 2>&1 || echo "WARNING: jq is not installed - the status line needs it"

echo ""
echo "Claude Code setup complete."
echo "Run 'claude' to log in; plugins from settings.json are installed on first start."
