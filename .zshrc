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

export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Calling nvm use automatically in a directory with a .nvmrc file. 
# Place this after nvm initialization! 
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

# Add autocomplete to Homebrew functions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

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

