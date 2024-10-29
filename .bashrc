# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/bashrc.pre.bash" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/bashrc.pre.bash"
export PATH="$HOME/.bin:$PATH"### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
export PATH="/usr/local/git/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source ~/.git-completion.bash


[[ -f "$HOME/fig-export/dotfiles/dotfile.bash" ]] && source "$HOME/fig-export/dotfiles/dotfile.bash"

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/bashrc.post.bash" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/bashrc.post.bash"
