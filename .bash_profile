# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/bash_profile.pre.bash" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/bash_profile.pre.bash"
# Make git look nicely - https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
source ~/.git-prompt.sh

# Git autocomplete from https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion

if [ -f `brew --prefix`/etc/bash_completion.d/git-completion.bash ]; then
  . `brew --prefix`/etc/bash_completion.d/git-completion.bash
fi

# Git aliases
alias ga='git add'
alias gac='git add . && git commit -m'
alias gc='git checkout'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias gp='git pull'
alias gps='git push'
alias gs='git status'

# Faster navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Color LS
colorflag="-G"
alias ls="command ls ${colorflag}"
alias l="ls -lF ${colorflag}" # all files, in long format
alias la="ls -laF ${colorflag}" # all files inc dotfiles, in long format
alias lsd='ls -lF ${colorflag} | grep "^d"' # only directories

# npm dance
alias fuckyounpm='sudo rm -r node_modules && npm install'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # This loads nvm

[[ -s "$HOME/.avn/bin/avn.sh" ]] && source "$HOME/.avn/bin/avn.sh" # load avn

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
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

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/bash_profile.post.bash" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/bash_profile.post.bash"
