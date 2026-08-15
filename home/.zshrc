# Shared zsh config, linked on every platform.
# Platform-specific bits live in ~/.zshrc.pre.local and ~/.zshrc.local,
# supplied by macos/home/ or ubuntu/home/ via link.sh.

# Anything that must run before oh-my-zsh (e.g. CodeWhisperer's pre block).
[[ -f "$HOME/.zshrc.pre.local" ]] && source "$HOME/.zshrc.pre.local"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-z
)

# Add autocomplete to Homebrew functions. This must be done before sourcing oh-my-zsh.
# Path is hardcoded rather than $(brew --prefix) to avoid a subprocess on every shell start.
# No compinit here on purpose: oh-my-zsh runs it below, and calling it twice rebuilds
# the completion dump twice (~270ms). No-op off Homebrew.
if [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  FPATH=/opt/homebrew/share/zsh/site-functions:$FPATH
fi

ZSH_DISABLE_COMPFIX="true"

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"

# Locate nvm.sh wherever this machine keeps it (git install, Homebrew, Intel Homebrew).
for _nvm_candidate in \
  "$NVM_DIR/nvm.sh" \
  /opt/homebrew/opt/nvm/nvm.sh \
  /usr/local/opt/nvm/nvm.sh
do
  [[ -r "$_nvm_candidate" ]] && { NVM_SH="$_nvm_candidate"; break }
done
unset _nvm_candidate

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
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
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

# Create a new directory and enter it
function mk() {
  mkdir -p "$@" && cd "$@"
}

# Decode base64 strings
decode () {
  echo "$1" | base64 -d ; echo
}

# Pure prompt
fpath+=$HOME/.zsh/pure
autoload -U promptinit; promptinit
prompt pure

ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

export GPG_TTY=$(tty)

# Start SSH agent and add key
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval "$(ssh-agent -s)"
  [ -f "$HOME/.ssh/id_ed25519" ] && ssh-add "$HOME/.ssh/id_ed25519"
fi

export PATH="$HOME/.local/bin:$PATH"

[[ -d "$HOME/.pyenv/shims" ]] && export PATH="$HOME/.pyenv/shims:$PATH"

# Platform-specific config.
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
