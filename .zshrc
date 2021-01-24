# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

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
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

ZSH_DISABLE_COMPFIX="true"

source $ZSH/oh-my-zsh.sh

# To use "$EDITOR" as a variable in the shell, we need to set which editor to use. In this case it's VS Code.
export VISUAL="code -w"
export EDITOR="$VISUAL"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bash_completion"  # This loads nvm bash_completion

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

# Add autocomplete to Homebrew functions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# Create a new directory and enter it
function mk() {
  mkdir -p "$@" && cd "$@"
}

alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

fpath+=$HOME/.zsh/pure 
autoload -U promptinit; promptinit 
prompt pure

ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
