# CodeWhisperer pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zprofile.pre.zsh"
export PATH="/usr/local/opt/avr-gcc/bin:$PATH"
eval $(/opt/homebrew/bin/brew shellenv)

eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# MacPorts Installer addition on 2024-10-23_at_12:54:08: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

# CodeWhisperer post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/codewhisperer/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/codewhisperer/shell/zprofile.post.zsh"