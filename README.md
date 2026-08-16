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
  .tmux.conf
  .hushlogin
macos/
  home/                   Linked on top of home/ on macOS
    .zprofile             Homebrew shellenv
    .zshrc.local          VS Code as EDITOR, BSD ls colors, notif()
    .gitconfig.local      VS Code as editor/difftool/mergetool
  vscode/
    settings.json         Editor settings, linked via links.conf
    keybindings.json      Custom key bindings
  links.conf              Targets that aren't at the top level of $HOME
  Brewfile
  defaults.sh             ~150 macOS system preferences
  verify.sh               Checks defaults.sh against the running system
  iterm2-marks.json       iTerm2 dynamic profile
  install.sh
ubuntu/
  home/                   Linked on top of home/ on Ubuntu
    .zprofile
    .zshrc.local          vim as EDITOR, Claude Code tmux helpers (cc/ccw/ccls/cckill)
    .gitconfig.local      vim as editor
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

It is idempotent — re-running only reports `ok` for links already in place. It
also removes links pointing into this repo whose source has since been deleted,
so dropping a file from `home/` doesn't leave a broken symlink behind. Links
pointing anywhere else are never touched, broken or not.

### Adding a dotfile

Drop it in `home/` (shared) or `<platform>/home/` (platform-specific) and re-run
`./link.sh`. Because the files in `$HOME` are symlinks into this repo, editing
`~/.zshrc` edits `home/.zshrc` directly; commit from `~/dotfiles` as usual.

### Files that don't live at the top level of $HOME

The `home/` convention can only produce `~/.something`. For anything deeper — VS
Code keeps its config under `~/Library/Application Support/` — add a line to the
platform's `links.conf`:

```
vscode/settings.json      ~/Library/Application Support/Code/User/settings.json
```

The first field is the source, relative to the `links.conf`; everything after it
is the destination, so paths containing spaces need no quoting. `~` and `$HOME`
are expanded, and missing directories are created. A source that doesn't exist,
or a line with no destination, is reported and makes `link.sh` exit non-zero
instead of silently doing nothing.

VS Code writes through the symlink, so changing a setting in the UI updates the
repo. If an update ever replaces the link with a plain file, `./link.sh --dry-run`
will show it as needing to be re-linked.

### Shared vs platform-specific

Files with the same name can't both be linked, so the shared files load the
platform ones by name rather than being overwritten:

- `home/.zshrc` sources `~/.zshrc.local` at the bottom, and `~/.zshrc.pre.local`
  at the top for anything that has to load before oh-my-zsh. Both are guarded, so
  a platform that supplies neither costs nothing — nothing needs the pre hook
  today, but it stays for the tools that do.
- `home/.gitconfig` ends with `[include] path = ~/.gitconfig.local`. Git applies
  later values last, so the platform file wins.

Anything genuinely shared — the `ghf`/`mk`/`decode` functions, the NVM lazy-loader
and `.nvmrc` auto-switching, Pure prompt, plugin list — lives once in `home/`.

## What the install scripts do

**`macos/install.sh`** — Xcode CLT check, Homebrew, `brew bundle` from
`macos/Brewfile`, oh-my-zsh, Pure prompt, zsh plugins, `link.sh macos`, iTerm2
profile, then offers to run `macos/defaults.sh`. Every step is guarded, so it is
safe to re-run.

**`ubuntu/install.sh`** — apt packages, oh-my-zsh, Pure prompt, zsh plugins, NVM,
diff-so-fancy, `link.sh ubuntu`, sets zsh as the default shell, installs Claude
Code, and optionally provisions a non-root dev user with the same setup.

`macos/defaults.sh` is kept out of the automatic path: it uses `sudo`, clears the
Dock, and needs a logout to fully apply.

### The Brewfile

`macos/Brewfile` lists exactly what is installed on the Mac — CLI formulae, cask
apps, App Store apps (`mas`) and VS Code extensions — so a new machine needs no
manual installing. Only top-level packages are listed; Homebrew resolves
dependencies itself.

The Brewfile covers VS Code *extensions*; the editor's own `settings.json` and
`keybindings.json` are symlinked separately through `macos/links.conf`, so a new
machine gets the configuration as well as the plugins.

```zsh
brew bundle       --file=macos/Brewfile          # install everything
brew bundle check --file=macos/Brewfile          # what's missing?
brew bundle dump --force --file=macos/Brewfile   # regenerate from current state
```

One step can't be automated: **you must be signed into the App Store** before the
`mas` entries will install. Apple removed programmatic sign-in and mas 7 can't
report sign-in status, so `install.sh` pauses and asks you to sign in.

`brew bundle cleanup` reports superseded keg versions alongside genuinely unused
packages — seeing `python@3.12/3.12.9` listed while `3.12.14` is installed is
normal. Still read its output before `--force`: it also removes orphaned
dependencies, and an older installed build can link against one that the current
formula no longer declares.

### Verifying macOS settings

`macos/defaults.sh` is write-only: running it sets ~150 preferences but tells you
nothing about what the machine currently looks like. `macos/verify.sh` closes that
loop by reading every setting back and comparing.

```zsh
./macos/verify.sh          # report drift only
./macos/verify.sh --all    # also list settings that match
./macos/verify.sh --quiet  # no output, just the exit status
```

Exit status is 0 when nothing has drifted and 1 otherwise, so it works in a
pre-commit hook or CI step. It handles `-currentHost`, expands `${HOME}`, and
where a key is written more than once compares only the last write, since that
is the one that survives.

Four categories come out:

- **drift** — the system value differs from what the script would set
- **not set** — the script sets it but the system has no value, usually because
  that app has never been launched
- **check by hand** — `-dict-add` and `-array` entries, which build structures
  rather than set a single value
- **not covered** — the `pmset` and `chflags` lines, listed explicitly so they
  are not silently assumed correct

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
