# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-z
)

ZSH_DISABLE_COMPFIX="true"

source $ZSH/oh-my-zsh.sh

# Editor
export VISUAL="vim"
export EDITOR="vim"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Calling nvm use automatically in a directory with a .nvmrc file.
# Source: https://github.com/nvm-sh/nvm#calling-nvm-use-automatically-in-a-directory-with-a-nvmrc-file
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

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

# Create a new directory and enter it
function mk() {
  mkdir -p "$@" && cd "$@"
}

# Pure prompt
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Bare-repo dotfiles management
alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Decode base64 strings
decode () {
  echo "$1" | base64 -d ; echo
}

# pyenv
export PATH="${HOME}/.pyenv/shims:${PATH}"

export GPG_TTY=$(tty)
