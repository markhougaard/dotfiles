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

export GPG_TTY=$(tty)

# === Claude Code helpers ===

# Ensure Claude Code is on PATH
export PATH="$HOME/.local/bin:$HOME/.claude/bin:$PATH"

# cc — Start or reattach to a Claude Code tmux session
#   Usage:
#     cc              — opens Claude Code in a persistent tmux session
#     cc ~/projects   — opens Claude Code in that directory
cc() {
    local dir="${1:-.}"
    local session_name="claude"

    # If we're already inside this tmux session, just run claude
    if [[ "${TMUX:-}" ]] && tmux display-message -p '#S' 2>/dev/null | grep -q "^${session_name}$"; then
        cd "$dir" && claude
        return
    fi

    # Try to attach to existing session
    if tmux has-session -t "${session_name}" 2>/dev/null; then
        echo "Reattaching to existing Claude Code session..."
        tmux attach-session -t "${session_name}"
    else
        # Create new session, cd to dir, and launch claude
        echo "Starting new Claude Code session..."
        tmux new-session -d -s "${session_name}" -c "$dir"
        tmux send-keys -t "${session_name}" "claude" Enter
        tmux attach-session -t "${session_name}"
    fi
}

# ccw — Start Claude Code in a named tmux session (for multiple projects)
#   Usage:
#     ccw markdown ~/projects/realtime-markdown-editor
#     ccw blog ~/projects/blog
ccw() {
    local name="${1:?Usage: ccw <name> [directory]}"
    local dir="${2:-.}"

    if tmux has-session -t "cc-${name}" 2>/dev/null; then
        tmux attach-session -t "cc-${name}"
    else
        tmux new-session -d -s "cc-${name}" -c "$dir"
        tmux send-keys -t "cc-${name}" "claude" Enter
        tmux attach-session -t "cc-${name}"
    fi
}

# ccls — List all active Claude Code tmux sessions
ccls() {
    echo "Active Claude Code sessions:"
    tmux list-sessions 2>/dev/null | grep -E "^(claude|cc-)" || echo "  (none)"
}

# cckill — Kill a specific or all Claude Code sessions
cckill() {
    local target="${1:-}"
    if [[ -z "$target" ]]; then
        echo "Killing all Claude Code sessions..."
        tmux list-sessions -F '#S' 2>/dev/null | grep -E "^(claude|cc-)" | while read -r s; do
            tmux kill-session -t "$s"
            echo "  -> killed $s"
        done
    else
        tmux kill-session -t "cc-${target}" 2>/dev/null || tmux kill-session -t "${target}" 2>/dev/null
        echo "Killed session: ${target}"
    fi
}

# === End Claude Code helpers ===
