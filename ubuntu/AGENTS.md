# Ubuntu: the state a machine should be in

This file replaces `ubuntu/install.sh`. It describes what a headless Ubuntu machine
looks like once these dotfiles are set up, how to check each part, and how to fix
what doesn't match. It covers the user's shell environment only. What a machine is
*for* (the backup Pi, a server) is described in that machine's own repo.

## How to use this file

- **Check** ("does this box match?"): run every check, change nothing, and report.
- **Apply** ("set this box up", "make it match"): run every check, fix the ones that
  fail in the order listed, then run the checks again. Ask before any step marked
  **(ask)**.
- Either way, finish with a table: item, what was found, what was done.
- If the machine has something this file doesn't mention, report it and leave it
  alone. It may belong to another repo. If the machine does something better than
  this file says, say so: the fix may be to update this file.

## Rules

- Run as the user being set up, never as `sudo claude`. Under sudo `$HOME` is
  `/root`, so everything would land on root. Use `sudo` for single commands.
- Paths: user tools go in `~/.local/{bin,share}`, never in `/usr/{bin,lib}`. If
  something has to be system-wide, put it in `/usr/local` (FHS).
- Versions pinned here are on purpose. To change one, edit this file first, then
  the machine.
- systemd user units in `ubuntu/systemd/` are **copied** to
  `~/.config/systemd/user/`, not linked. systemd treats a symlinked unit file as a
  "linked" unit, and `systemctl disable`/`reenable` deletes the link. Check with
  `diff`, and copy with `install -m 644`.
- Use `sudo chsh <user>`, not plain `chsh`. Cloud-init users often have a locked
  password and passwordless sudo, and plain `chsh` asks for the password.

## Bootstrap (by hand, before this file can be used)

A fresh Ubuntu server already has `git` and `curl`.

```bash
curl -fsSL https://claude.ai/install.sh | bash     # Claude Code, to ~/.local/bin
git clone https://github.com/markhougaard/dotfiles.git ~/dotfiles
cd ~/dotfiles && ~/.local/bin/claude "apply ubuntu/AGENTS.md"
```

## 1. apt packages

Must be installed: `zsh git curl wget vim build-essential gpg git-lfs tmux ripgrep
htop jq unzip gh`, plus `nodejs npm` **only where item 11 applies**.

- Check: `dpkg-query -W -f='${Status}\n' <pkg>` prints `install ok installed` for each.
- Fix: `sudo apt update && sudo apt install -y <the missing ones>`
- `nodejs` and `npm` are for ob (item 11), not for development. Use NVM for that.
  Where another repo owns ob (item 11's first check), they aren't needed: don't
  install them, and report a system node that's there anyway (it may belong to that
  repo; the server has none on purpose).
- `gh` is required: `ubuntu/home/.gitconfig.local` gets GitHub credentials from
  `/usr/bin/gh`. After installing it, the user runs `gh auth login` once (it's
  interactive). Check with `gh auth status`.

## 2. Login shell is zsh

- Check: `getent passwd "$USER" | cut -d: -f7` equals `command -v zsh`. Use passwd,
  not `$SHELL`, which is only the current session's shell.
- Fix: `sudo chsh -s "$(command -v zsh)" "$USER"`

## 3. oh-my-zsh, plugins and prompt

| Must exist | Source |
|---|---|
| `~/.oh-my-zsh/oh-my-zsh.sh` | `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc` |
| `~/.oh-my-zsh/custom/plugins/zsh-autosuggestions` | `git clone https://github.com/zsh-users/zsh-autosuggestions` |
| `~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting` | `git clone https://github.com/zsh-users/zsh-syntax-highlighting.git` |
| `~/.oh-my-zsh/custom/plugins/zsh-z` | `git clone https://github.com/agkozak/zsh-z` |
| `~/.zsh/pure` | `git clone https://github.com/sindresorhus/pure.git` |

- Check: each path exists (plugins and Pure are git checkouts).
- Use `--keep-zshrc`: without it the installer writes its own `~/.zshrc`, and
  item 6 then has to back it up.
- None of these are pinned. They update themselves (oh-my-zsh) or by `git pull`.

## 4. NVM

- Must be: NVM **v0.40.1** in `~/.nvm`.
- Check: `jq -r .version ~/.nvm/package.json` prints `0.40.1`.
- Fix: `curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash`.
  Then remove any lines the installer added to `~/.zshrc` or `~/.bashrc`. The shared
  `home/.zshrc` already loads NVM lazily, and `~/.zshrc` is a link into this repo,
  so a line added there shows up in `git status`.
- No NVM node version is required. If `~/.nvm/alias/default` names an installed
  version, `home/.zshrc` puts it first on `PATH`. Otherwise the apt `nodejs` from
  item 11 is used. Switch with `nvm use` as much as you like: `ob` (item 11)
  doesn't use `PATH` to find node, so switching can't break it.

## 5. diff-so-fancy

`home/.gitconfig` uses it as the pager, so git output breaks without it.

- Must be: a checkout in `~/.local/share/diff-so-fancy`, linked from
  `~/.local/bin/diff-so-fancy`.
- Check: `readlink ~/.local/bin/diff-so-fancy` points into
  `~/.local/share/diff-so-fancy`, and `command -v diff-so-fancy` finds it there.
- Fix:
  ```bash
  git clone --depth 1 https://github.com/so-fancy/diff-so-fancy.git ~/.local/share/diff-so-fancy
  mkdir -p ~/.local/bin && ln -sf ~/.local/share/diff-so-fancy/diff-so-fancy ~/.local/bin/
  ```
- Why not npm: it isn't in apt, and `npm install -g` needs root whenever apt's npm
  is first on `PATH`. It's a Perl script, and it finds its `lib/` through the link.
- If another copy is found, for example `/usr/local/bin/diff-so-fancy` from an old
  `sudo npm -g` install, report it. Removing it is **(ask)**.

## 6. Dotfiles are linked

- Check: `zsh ~/dotfiles/link.sh --dry-run ubuntu` prints only `ok` and `skip`
  lines and exits 0.
- A `skip` line comes from `~/.config/dotfiles/skip`: a machine-local list of link
  destinations (one per line, `~` expanded, `#` comments) that `link.sh` leaves
  alone because another repo owns them on that machine. It is not tracked. Don't
  remove an entry to make the check pass; report it.
- Fix: `zsh ~/dotfiles/link.sh ubuntu`. It moves anything in the way to
  `~/.dotfiles-backup/<timestamp>/` and removes stale links into the repo.
- Do this after items 3–5, so the installers there can't overwrite a linked file.

## 7. GnuPG

- Must be: `~/.gnupg` is mode `700`. gpg refuses to trust a group-writable
  homedir. `link.sh` creates the directory with the default umask, so the mode can
  end up wrong.
- Check: `stat -c %a ~/.gnupg` prints `700`.
- Fix: `zsh ~/dotfiles/link.sh ubuntu`. It creates `~/.gnupg` as `700` and fixes the
  mode if something else loosened it (`PRIVATE_DIRS` in `link.sh`).
- Must **not** be: any secret key. The signing key is only on the Mac, and
  `ubuntu/home/.gitconfig.local` turns signing off. Check:
  `gpg --list-secret-keys` prints nothing. If it finds a key, report it and do
  nothing else.
- The public key can be imported (`gpg --import ~/dotfiles/gnupg/mark-hougaard.asc`)
  to verify signed commits, but it isn't required.

## 8. ssh-agent comes from systemd

- Must be: the shell doesn't start its own agent. `SSH_AUTH_SOCK` points at the
  systemd user agent's socket.
- Check: `systemctl --user is-enabled ssh-agent.socket` prints `enabled`. In a
  login shell without a forwarded agent (`ssh -A` sets its own), `echo
  $SSH_AUTH_SOCK` is `/run/user/<uid>/openssh_agent`, and `pgrep -u "$USER" -fx
  'ssh-agent -s'` finds nothing.
- Fix: `systemctl --user enable --now ssh-agent.socket`
- **No `ssh-agent.socket`** (`systemctl --user cat ssh-agent.socket` fails; Ubuntu
  24.04, OpenSSH 9.6, whose `ssh-agent.service` only starts in a graphical
  session): use `ubuntu/systemd/openssh-agent.service` instead, same socket path.
  Check: `diff` against `~/.config/systemd/user/openssh-agent.service` is empty
  and `systemctl --user is-active openssh-agent` = `active`. Fix: `install -m 644`
  it there, `systemctl --user daemon-reload && systemctl --user enable --now
  openssh-agent`. Without either, `home/.zshrc` falls back to `ssh-agent -s` in
  every shell and those agents never exit: kill the `ssh-agent -s` ones no process
  uses any more (one whose socket no `/proc/*/environ` names).

## 9. Claude Code

- Must be: `~/.local/bin/claude` exists. The bootstrap installs it. It updates
  itself, so don't pin it.

## 10. tk (ticket)

The `tk` command the repos' `.tickets/` use. It's a single bash script.

- Must be: `~/.local/bin/ticket` exists and is executable, and `~/.local/bin/tk` is a
  link to `ticket`.
- Check: `tk help` runs.
- Fix: download the `ticket` script from github.com/wedow/ticket (the same tool the
  Mac gets from the `wedow/tools` tap) into `~/.local/bin/ticket`, `chmod +x`, then
  `ln -s ticket ~/.local/bin/tk`.

## 11. ob and continuous Obsidian Sync

`~/marks-vault` is kept in sync with Obsidian Sync by `ob` (the npm package
`obsidian-headless`), which runs all the time as a systemd user service.

**First: does another repo own this here?** On some machines ob and the sync are
installed by that machine's own repo instead (the server: `/opt/multisite`
bootstrap pins ob under `/opt` and runs a **system** unit, so no code from the
user's home runs in the service). Check: `systemctl cat obsidian-sync.service`
shows a file under `/etc/systemd/system/`. If it does:

- Skip the rest of this item. Report "owned by the system unit" and leave it alone.
- `~/.config/dotfiles/skip` must list `~/.local/bin/ob` (item 6), so the wrapper
  doesn't shadow the system's `ob` with one that points at a prefix this machine
  doesn't have. Add the line if it's missing.
- Never install or enable the user unit there: two `ob sync` processes on one vault
  conflict.

**Node for ob.** ob uses `better-sqlite3`, a native addon compiled for one node
ABI, so ob breaks on any other node major version. ob therefore always runs on
apt's node and never on NVM's:

- apt packages `nodejs` and `npm` (Ubuntu 26.04: node 22; ob needs >= 22).
- ob is installed into its own prefix with apt's npm:
  `/usr/bin/npm install -g --prefix ~/.local/share/obsidian-headless obsidian-headless@0.0.14`
- `~/.local/bin/ob` links to `ubuntu/bin/ob` (via `ubuntu/links.conf`, item 6). That
  wrapper runs `/usr/bin/node .../cli.js`, so `nvm use` can't change which node ob
  gets.
- If a release upgrade moves apt's node to a new major version, run
  `/usr/bin/npm rebuild --prefix ~/.local/share/obsidian-headless -g`, then restart
  the service.
- Never `sudo npm install -g` it into `/usr/local`. An old copy there is found on
  `PATH` after `~/.local/bin` and gets out of date. Report it; removing it with
  `sudo npm rm -g obsidian-headless` is **(ask)**.

**The service:**

| Must be | Check | Fix |
|---|---|---|
| ob pinned at 0.0.14 | `ob --version` | the npm install above |
| `command -v ob` is `~/.local/bin/ob` | same | item 6 |
| signed in, vault configured | `ob sync-list-local` lists `~/marks-vault` | `ob login`, then `ob sync-setup --path ~/marks-vault` against the remote vault **marks** (both interactive: the user runs them) |
| sync settings | `ob sync-status --path ~/marks-vault`: bidirectional, conflict strategy merge, device name = hostname, file types image/audio/pdf/video, config syncing off | `ob sync-config --path ~/marks-vault ...` |
| unit installed | `diff ubuntu/systemd/obsidian-sync.service ~/.config/systemd/user/obsidian-sync.service` shows nothing | `install -m 644 ubuntu/systemd/obsidian-sync.service ~/.config/systemd/user/ && systemctl --user daemon-reload` |
| enabled and running | `systemctl --user is-enabled obsidian-sync` = `enabled`, `is-active` = `active` | `systemctl --user enable --now obsidian-sync` |
| runs without a login | `loginctl show-user "$USER" -p Linger` = `Linger=yes` | `sudo loginctl enable-linger "$USER"` |
| in sync | `journalctl --user -u obsidian-sync -n 20` shows `Fully synced` and no repeated errors | `systemctl --user restart obsidian-sync` |

The unit restarts ob 30 s after a crash. More than 5 starts in 10 minutes stops
it: `systemctl --user reset-failed obsidian-sync` clears that once the cause is fixed.

## Optional: only for the machines that need it

Install these only when the machine has the job they're for. In a check, report
whether they're there and leave it at that. Their configuration lives in the repo
for that job, not here.

- **restic**: the backup Pi (`pi4`) pulls the server's backups into a restic
  repository. Package: apt `restic` (Ubuntu main). The rest (units, keys, the
  encrypted drive) is set up by `pi/setup.sh` and `pi/disk.sh` in the multisite
  repo. Follow `pi/AGENTS.md` there, not this file.
- **tailscale**: for machines that have to be reachable on the tailnet. Package:
  apt `tailscale` from Tailscale's own repo, `https://pkgs.tailscale.com/stable/ubuntu`
  (their install script `https://tailscale.com/install.sh` adds the repo and the
  key). Then `sudo tailscale up` (interactive: the user signs in). Check:
  `tailscale status`.

## Optional: a dev user (ask, and only when asked)

On a new server set up as root, create a non-root user to work as:

1. `adduser --disabled-password --gecos "" <user>`, then add them to `sudo`, and to
   `docker` if that group exists.
2. Copy `/root/.ssh/authorized_keys` to `~<user>/.ssh/` (dir `700`, file `600`,
   owned by the user).
3. Give them their own clone of the dotfiles in `~<user>/dotfiles`. Don't share
   root's: a shared repo has to be readable by everyone, and pruning stale links
   assumes one owner.
4. Apply items 2–11 as that user (`sudo -iu <user>`). They run `claude` and
   `gh auth login` once themselves.
