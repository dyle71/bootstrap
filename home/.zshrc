autoload -Uz compinit
compinit

zstyle ':completion:*' menu select

ZSH_THEME="powerlevel10k/powerlevel10k"
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

ZNAP_REPOS="${HOME}/.znap-repos"
source ${ZNAP_REPOS}/znap/znap.zsh
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting
znap prompt romkatv/powerlevel10k

[[ ! -f ~/.zshrc.dyle ]] || source ~/.zshrc.dyle

