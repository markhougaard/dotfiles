# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.pre.zsh"
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-z
)

# Add autocomplete to Homebrew functions. This must be done before sourcing oh-my-zsh.
# Path is hardcoded rather than $(brew --prefix) to avoid a subprocess on every shell start.
# No compinit here on purpose: oh-my-zsh runs it below, and calling it twice rebuilds
# the completion dump twice (~270ms).
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  FPATH=/opt/homebrew/share/zsh/site-functions:$FPATH
fi

ZSH_DISABLE_COMPFIX="true"

source $ZSH/oh-my-zsh.sh

# To use "$EDITOR" as a variable in the shell, we need to set which editor to use. In this case it's VS Code.
export VISUAL="code -w"
export EDITOR="$VISUAL"

export NVM_DIR="$HOME/.nvm"
NVM_SH="/opt/homebrew/opt/nvm/nvm.sh"

# Put the default node version straight on PATH instead of sourcing nvm.sh (~300ms).
# node/npm/npx stay immediately available; nvm.sh only loads if you actually call nvm.
if [[ -r "$NVM_DIR/alias/default" ]]; then
  _nvm_default="$(<"$NVM_DIR/alias/default")"
  [[ -d "$NVM_DIR/versions/node/$_nvm_default/bin" ]] &&
    PATH="$NVM_DIR/versions/node/$_nvm_default/bin:$PATH"
  unset _nvm_default
fi

# Real nvm loads on first invocation, then re-dispatches.
nvm() {
  unset -f nvm
  [ -s "$NVM_SH" ] && \. "$NVM_SH"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] &&
    \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
  nvm "$@"
}

# Auto-switch node when a directory has an .nvmrc.
# The upward walk is pure zsh, so a cd into a directory without .nvmrc costs nothing
# and never forces nvm to load.
autoload -U add-zsh-hook
_find_nvmrc() {
  local d="$PWD"
  while [[ -n "$d" ]]; do
    [[ -f "$d/.nvmrc" ]] && { print -r -- "$d/.nvmrc"; return 0 }
    d="${d%/*}"
  done
  return 1
}
load-nvmrc() {
  local nvmrc_path
  if ! nvmrc_path="$(_find_nvmrc)"; then
    # No .nvmrc here. Only revert if nvm is already loaded — don't load it just to revert.
    if [[ -n "$NVM_BIN" ]] && typeset -f nvm_find_nvmrc >/dev/null; then
      [[ "$(nvm version)" != "$(nvm version default)" ]] && nvm use default >/dev/null
    fi
    return
  fi

  local node_version nvmrc_node_version
  node_version="$(nvm version)"
  nvmrc_node_version="$(nvm version "$(<"$nvmrc_path")")"

  if [[ "$nvmrc_node_version" == "N/A" ]]; then
    nvm install
  elif [[ "$nvmrc_node_version" != "$node_version" ]]; then
    nvm use
  fi
}
add-zsh-hook chpwd load-nvmrc

# ghf - [G]rep [H]istory [F]or top ten commands and execute one
# usage:
#  Most frequent command in recent history
#   ghf
#  Most frequent instances of {command} in all history
#   ghf {command}
#  Execute {command-number} after a call to ghf
#   !! {command-number}
function latest-history { history | tail -n 50 ; }
function grepped-history { history | grep "$1" ; }
function chop-first-column { awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}' ; }
function add-line-numbers { awk '{print NR " " $0}' ; }
function top-ten { sort | uniq -c | sort -r | head -n 10 ; }
function unique-history { chop-first-column | top-ten | chop-first-column | add-line-numbers ; }
function ghf {
  if [ $# -eq 0 ]; then latest-history | unique-history; fi
  if [ $# -eq 1 ]; then grepped-history "$1" | unique-history; fi
  if [ $# -eq 2 ]; then
    `grepped-history "$1" | unique-history | grep ^$2 | chop-first-column`;
  fi
}

# Add colors to Terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# (Homebrew site-functions already added to FPATH above, before oh-my-zsh.)

# Create a new directory and enter it
function mk() {
  mkdir -p "$@" && cd "$@"
}

fpath+=$HOME/.zsh/pure 
autoload -U promptinit; promptinit 
prompt pure

ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias cor="!git for-each-ref --sort=-committerdate --format='%(refname:short) (%(committerdate:relative))' refs/heads | fzf --reverse --height 35% --nth 1 | awk '{print $1}' | xargs git checkout"

function notif() {
  osascript -e 'display notification "Done" with title "🎉"'
}

decode () {
  echo "$1" | base64 -d ; echo
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/marks/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/marks/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/marks/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/marks/google-cloud-sdk/completion.zsh.inc'; fi

# Install z, used to track most used directories: https://github.com/rupa/z
. /opt/homebrew/etc/profile.d/z.sh

export PATH="${HOME}/.pyenv/shims:${PATH}"


[[ -f "$HOME/fig-export/dotfiles/dotfile.zsh" ]] && builtin source "$HOME/fig-export/dotfiles/dotfile.zsh"

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zshrc.post.zsh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export GPG_TTY=$(tty)

# Start SSH agent and add key
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519
fi

export PATH="$HOME/.local/bin:$PATH"
