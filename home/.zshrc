ZSH_THEME="powerlevel10k/powerlevel10k"
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source /usr/local/src/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ~/.zshrc.dyle ]] || source ~/.zshrc.dyle

ZNAP_REPOS="/usr/local/src/znap-repos"
[[ ! -f ${ZNAP_REPOS}/znap/znap.zsh ]] || source ${ZNAP_REPOS}/znap/znap.zsh
