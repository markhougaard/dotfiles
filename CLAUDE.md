# Dotfiles Repository

Personal dotfiles for shell configuration, git settings, and development environment
setup. Supports macOS workstations and headless Ubuntu servers from one repo.

## Overview

An ordinary git repo cloned to `~/dotfiles`. `link.sh` symlinks files into `$HOME`.
There is no `dot` alias and no bare repo — plain `git` works in `~/dotfiles`.

## Repository Structure

```
home/                   Shared config, linked on every platform
  .zshrc                oh-my-zsh, plugins, NVM, prompt, shared functions
  .gitconfig            identity, aliases, colors, diff-so-fancy
  .gitignore_global     referenced by core.excludesfile
  .hushlogin
macos/
  home/
    .zprofile           Homebrew shellenv, Obsidian CLI, CodeWhisperer blocks
    .zshrc.pre.local    CodeWhisperer pre block (loads before oh-my-zsh)
    .zshrc.local        VS Code EDITOR, CLICOLOR/LSCOLORS, z, notif()
    .gitconfig.local    VS Code as editor/difftool/mergetool
  Brewfile              Homebrew packages, casks, Mac App Store apps
  defaults.sh           ~150 `defaults write` system preferences
  verify.sh             Reads defaults.sh settings back and reports drift
  iterm2-marks.json     iTerm2 dynamic profile
  midt.terminal         Terminal.app theme
  install.sh
ubuntu/
  home/
    .zprofile           pyenv shims
    .zshrc.local        vim EDITOR, Claude Code tmux helpers
    .gitconfig.local    vim as editor
    .tmux.conf          Ctrl+A prefix, mouse on, 50k scrollback
  install.sh            apt, oh-my-zsh, plugins, NVM, dev-user provisioning
link.sh                 Symlinks home/ then <platform>/home/ into $HOME
```

## Key Patterns

- **Plain repo + symlinks**: `link.sh [macos|ubuntu]` links `home/` first, then the
  platform directory on top. Existing files are moved to
  `~/.dotfiles-backup/<timestamp>/`. Idempotent; supports `--dry-run`.
- **Shared base, platform fragments**: two files with the same name can't both be
  linked, so the shared files load platform ones by name — `home/.zshrc` sources
  `~/.zshrc.pre.local` (top) and `~/.zshrc.local` (bottom); `home/.gitconfig` ends
  with `[include] path = ~/.gitconfig.local`. Put anything cross-platform in `home/`
  and only the divergence in the platform fragment.
- **Oh-My-Zsh** with plugins: git, zsh-autosuggestions, zsh-syntax-highlighting, zsh-z.
- **Pure prompt** installed to `$HOME/.zsh/pure`.
- **NVM**: the default node version goes straight on `PATH`; `nvm.sh` only loads on
  first actual `nvm` call (~300ms saved per shell). `.nvmrc` auto-switching walks up
  the tree in pure zsh, so a `cd` into a directory without `.nvmrc` costs nothing.
  `nvm.sh` is located by probing `$NVM_DIR`, then the Homebrew paths.
- **Conditional sourcing**: integrations use `[[ -f ... ]] && source ...` guards, so
  the shared files stay no-ops where a tool isn't installed.
- **Verifiable state**: `macos/verify.sh` parses `defaults.sh` and reads each key
  back off the system, exiting non-zero on drift. Prefer extending it over
  hand-checking settings; anything it cannot compare it reports rather than
  skipping silently.

## Editing Conventions

- Files in `$HOME` are symlinks into this repo — editing `~/.zshrc` edits
  `home/.zshrc`. Commit from `~/dotfiles`.
- Adding a dotfile means dropping it in `home/` or `<platform>/home/` and re-running
  `./link.sh`. No script changes needed; `link.sh` globs the directory.
- Keep `macos/defaults.sh` content alone unless asked — it is hand-tuned, and it
  stays out of the automatic install path because it needs `sudo` and a logout.
- Prefer guarding a path over hardcoding one. Several dead paths from an old
  `/Users/marks` home directory were removed; don't reintroduce absolute user paths.

## Development Notes

- `link.sh` and `macos/install.sh` are zsh; `ubuntu/install.sh` is bash. Check with
  `zsh -n` / `bash -n` after editing.
- `link.sh` globs `.[!.]*` so it skips `.` and `..`, with the `(N)` qualifier so an
  empty directory doesn't error under `set -u`. Non-dot files in `home/` are ignored
  by design.
- The iTerm2 profile is copied, not symlinked — iTerm2's DynamicProfiles watcher is
  unreliable with symlinks.
- `macos/home/.zshrc.local` sources rupa/z, which shadows the `zsh-z` plugin from the
  shared plugin list. Both provide `z`; the later one wins. Left as-is deliberately.
