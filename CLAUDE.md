# Dotfiles Repository

Personal dotfiles for shell configuration, git settings, and development environment setup.

## Overview

This repository was originally built for macOS with GUI apps. It is being adapted to also support headless Ubuntu servers. The goal is to keep the valuable cross-platform shell and git configurations while removing or gating macOS/GUI-specific parts.

## Repository Structure

```
.zshrc              # Primary shell config (oh-my-zsh, plugins, aliases, prompt)
.zprofile           # Zsh login profile (PATH setup, brew env)
.bash_profile       # Bash login profile (git aliases, navigation aliases)
.bashrc             # Bash non-login shell (PATH, nvm, git completion)
.gitconfig          # Git identity, aliases, diff/merge tools, colors
.git-prompt.sh      # Git branch/status in shell prompt
.git-completion.bash # Git tab completion for bash
.hushlogin          # Suppress login banner
.gitignore          # Global gitignore patterns
midt.terminal       # macOS Terminal.app theme (macOS-only)
ubuntu/
  .zshrc            # Ubuntu-specific zsh config (vim editor, standard NVM paths)
  .gitconfig        # Ubuntu-specific git config (vim editor, no VS Code)
  .zprofile         # Minimal Ubuntu PATH setup
  install.sh        # Ubuntu server install script (apt, oh-my-zsh, plugins, NVM)
dotfiles/
  README.md         # Setup documentation
  apps/Brewfile     # Homebrew package list (macOS-only)
  configs/marks.json # iTerm2 profile (macOS-only)
  scripts/
    bootstrap.sh    # Initial setup - clones bare repo to $HOME/.dotfiles
    install.sh      # Full install - brew, oh-my-zsh, plugins, macOS defaults
    macos.sh        # macOS system preferences (100% macOS-only)
```

## Key Patterns

- **Bare git repo pattern**: Uses `git clone --bare` into `$HOME/.dotfiles` with a `dot` alias so the home directory acts as a git working tree without a `.git` folder. The `dot` command replaces `git` for managing these files.
- **Oh-My-Zsh**: Primary shell framework with plugins: git, zsh-autosuggestions, zsh-syntax-highlighting, zsh-z.
- **Pure prompt**: Minimal zsh prompt theme installed to `$HOME/.zsh/pure`.
- **NVM**: Node version management with auto-switching on `.nvmrc` detection.
- **Conditional sourcing**: Many integrations use `[[ -f ... ]] && source ...` guards.

## macOS vs Cross-Platform

### macOS-only (irrelevant for Ubuntu server)
- `macos.sh` - entire file is `defaults write` commands
- `Brewfile` - Homebrew casks, Mac App Store apps, GUI apps
- `midt.terminal` - Terminal.app theme
- `configs/marks.json` - iTerm2 profile
- `bootstrap.sh` / `install.sh` - both have `uname == Darwin` checks
- CodeWhisperer/Fig integration blocks in shell configs
- `osascript` calls, `/opt/homebrew/` paths, `brew shellenv`
- VS Code as git editor/difftool

### Cross-platform (valuable on Ubuntu)
- Git aliases and configuration (identity, push behavior, colors, diff-so-fancy)
- Shell aliases (navigation `..`, `...`, git shortcuts `ga`, `gs`, etc.)
- Oh-My-Zsh + plugins (autosuggestions, syntax-highlighting, zsh-z)
- Pure prompt theme
- NVM setup and `.nvmrc` auto-switching
- Custom functions (`ghf`, `mk`, `decode`)
- `.hushlogin`, `.git-prompt.sh`, `.git-completion.bash`
- GPG setup

## Development Notes

- The install scripts currently reject non-macOS systems (`exit 1` on Linux). Any Ubuntu support needs new or modified scripts.
- `.gitconfig` has hardcoded macOS paths (`/Users/marks/`) and VS Code as editor. For a server, `vim` or `nano` is more appropriate.
- `.zprofile` is entirely macOS-specific (Homebrew paths, MacPorts, AVR-GCC).
- `.zshrc` mixes cross-platform config with macOS-specific integrations (Homebrew completions, `/opt/homebrew/` NVM paths, CodeWhisperer, Fig).
- `.bash_profile` references `brew --prefix` which won't exist on a standard Ubuntu server.
