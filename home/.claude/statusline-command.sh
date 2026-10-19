#!/usr/bin/env bash
# Claude Code status line — mirrors Powerlevel10k left-prompt segments:
#   context (user@host) · dir · git branch · model · context usage

input=$(cat)

user=$(whoami)
host=$(hostname -s)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory to ~
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# Git branch (skip optional locks so we never block)
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# Build the line with ANSI colors (terminal renders these dimmed)
printf "\033[32m%s@%s\033[0m \033[34m%s\033[0m" "$user" "$host" "$short_cwd"

if [ -n "$branch" ]; then
  printf " \033[33m(%s)\033[0m" "$branch"
fi

if [ -n "$model" ]; then
  if [ -n "$effort" ]; then
    printf " \033[36m[%s · %s]\033[0m" "$model" "$effort"
  else
    printf " \033[36m[%s]\033[0m" "$model"
  fi
fi

if [ -n "$used" ]; then
  printf " \033[35mctx:%.0f%%\033[0m" "$used"
fi

printf "\n"
