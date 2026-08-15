# Dotfiles

Personal dotfiles for macOS workstations and headless Ubuntu servers.

## Quick start

**macOS:**

```zsh
git clone https://github.com/markhougaard/dotfiles.git ~/dotfiles
~/dotfiles/macos/install.sh
```

**Ubuntu server:**

```bash
git clone https://github.com/markhougaard/dotfiles.git ~/dotfiles
bash ~/dotfiles/ubuntu/install.sh
```

This is an ordinary git repo. Use plain `git` in `~/dotfiles` — there is no alias
and nothing special about your home directory.

## Layout

```
home/                   Shared config, linked on every platform
  .zshrc                  sources ~/.zshrc.pre.local and ~/.zshrc.local
  .gitconfig              includes ~/.gitconfig.local
  .gitignore_global
  .hushlogin
macos/
  home/                   Linked on top of home/ on macOS
    .zprofile
    .zshrc.pre.local      CodeWhisperer pre block (must load before oh-my-zsh)
    .zshrc.local          VS Code as EDITOR, BSD ls colors, z, notif()
    .gitconfig.local      VS Code as editor/difftool/mergetool
  Brewfile
  defaults.sh             ~150 macOS system preferences
  iterm2-marks.json       iTerm2 dynamic profile
  midt.terminal           Terminal.app theme
  install.sh
ubuntu/
  home/                   Linked on top of home/ on Ubuntu
    .zprofile
    .zshrc.local          vim as EDITOR, Claude Code tmux helpers (cc/ccw/ccls/cckill)
    .gitconfig.local      vim as editor
    .tmux.conf
  install.sh
link.sh                 Symlinks home/ then <platform>/home/ into $HOME
```

## How linking works

`link.sh` symlinks every dotfile in `home/` into `$HOME`, then does the same for
`<platform>/home/`, so platform files land alongside the shared ones. Anything
already at a destination is moved to `~/.dotfiles-backup/<timestamp>/` first.

```zsh
./link.sh              # detect platform from uname
./link.sh macos        # force a platform
./link.sh --dry-run    # show what would change
```

It is idempotent — re-running only reports `ok` for links already in place.

### Adding a dotfile

Drop it in `home/` (shared) or `<platform>/home/` (platform-specific) and re-run
`./link.sh`. Because the files in `$HOME` are symlinks into this repo, editing
`~/.zshrc` edits `home/.zshrc` directly; commit from `~/dotfiles` as usual.

### Shared vs platform-specific

Files with the same name can't both be linked, so the shared files load the
platform ones by name rather than being overwritten:

- `home/.zshrc` sources `~/.zshrc.pre.local` at the top (before oh-my-zsh) and
  `~/.zshrc.local` at the bottom.
- `home/.gitconfig` ends with `[include] path = ~/.gitconfig.local`. Git applies
  later values last, so the platform file wins.

Anything genuinely shared — the `ghf`/`mk`/`decode` functions, the NVM lazy-loader
and `.nvmrc` auto-switching, Pure prompt, plugin list — lives once in `home/`.

## What the install scripts do

**`macos/install.sh`** — Xcode CLT check, Homebrew, `brew bundle` from
`macos/Brewfile`, oh-my-zsh, Pure prompt, zsh plugins, `link.sh macos`, iTerm2
profile, then offers to run `macos/defaults.sh`. Every step is guarded, so it is
safe to re-run.

### The Brewfile

`macos/Brewfile` lists exactly what is installed on the Mac — CLI formulae, cask
apps, App Store apps (`mas`) and VS Code extensions — so a new machine needs no
manual installing. Only top-level packages are listed; Homebrew resolves
dependencies itself.

```zsh
brew bundle       --file=macos/Brewfile          # install everything
brew bundle check --file=macos/Brewfile          # what's missing?
brew bundle dump --force --file=macos/Brewfile   # regenerate from current state
```

One step can't be automated: **you must be signed into the App Store** before the
`mas` entries will install. Apple removed programmatic sign-in and mas 7 can't
report sign-in status, so `install.sh` pauses and asks you to sign in.

Before using `brew bundle cleanup --force`, read its output. If Homebrew warns
about a circular dependency, its graph sort is unreliable and it will list
packages that *are* in the Brewfile.

**`ubuntu/install.sh`** — apt packages, oh-my-zsh, Pure prompt, zsh plugins, NVM,
diff-so-fancy, `link.sh ubuntu`, sets zsh as the default shell, installs Claude
Code, and optionally provisions a non-root dev user with the same setup.

`macos/defaults.sh` is kept out of the automatic path: it uses `sudo`, clears the
Dock, writes `nvram`, and needs a logout to fully apply.

## Notes

### Keyboard combinations

You can set keyboard combinations with the Terminal. The meta-keys are set as @ for
Command, $ for Shift, ~ for Alt and ^ for Ctrl. For system-wide shortcuts, you can
use -g instead of the app identifier, e.g.
`defaults write -g NSUserKeyEquivalents -dict-add "Menu Item" -string "@$~^k"`.
Find all current keyboard shortcuts with `defaults find NSUserKeyEquivalents`.
More info at <https://apple.stackexchange.com/questions/123382/is-there-a-way-to-save-your-custom-keyboard-shortcuts-in-a-config-file>
and <http://hints.macworld.com/article.php?story=20131123074223584>
and <https://ryanmo.co/2017/01/05/setting-keyboard-shortcuts-from-terminal-in-macos/>

### Removing the underline from zsh-syntax-highlighting

- <https://github.com/zsh-users/zsh-syntax-highlighting/issues/573>
