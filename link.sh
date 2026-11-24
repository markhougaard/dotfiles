#!/usr/bin/env zsh
#
# Symlink dotfiles into $HOME.
#
#   ./link.sh            # detect platform from uname
#   ./link.sh macos      # force a platform
#   ./link.sh ubuntu
#   ./link.sh --dry-run  # show what would happen, change nothing
#
# Links home/ first, then <platform>/home/ on top. Anything already at the
# destination is moved into ~/.dotfiles-backup/<timestamp>/ before linking.
# Safe to re-run: already-correct links are left alone.
#
# Files that do not live at the top level of $HOME (VS Code's settings, say)
# cannot be expressed by the home/ convention, so they are listed in a
# links.conf instead - see link_manifest() below for the format.

set -euo pipefail

REPO="${0:A:h}"
DRY_RUN=false
PLATFORM=""

for arg in "$@"; do
  case "$arg" in
    --dry-run)      DRY_RUN=true ;;
    macos|ubuntu)   PLATFORM="$arg" ;;
    -h|--help)      sed -n '2,13p' "$0"; exit 0 ;;
    *)              print -u2 "unknown argument: $arg"; exit 1 ;;
  esac
done

if [[ -z "$PLATFORM" ]]; then
  case "$(uname -s)" in
    Darwin) PLATFORM=macos ;;
    Linux)  PLATFORM=ubuntu ;;
    *)      print -u2 "unsupported platform: $(uname -s)"; exit 1 ;;
  esac
fi

if [[ ! -d "$REPO/$PLATFORM/home" ]]; then
  print -u2 "no such platform directory: $PLATFORM/home"
  exit 1
fi

BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

# Missing sources / malformed manifest lines. Reported as they are found, then
# turned into a non-zero exit at the end.
typeset -i PROBLEMS=0

# Machine-local opt-outs: destinations this machine must not get, because
# something else owns them there (on the server, /opt/multisite installs ob and
# runs Obsidian Sync as a system service). One destination per line, ~ and $HOME
# expanded, # comments. Untracked on purpose: it describes one machine, not the
# platform.
SKIP_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/skip"
typeset -a SKIP=()
if [[ -r "$SKIP_FILE" ]]; then
  # "|| [[ -n $line ]]" keeps a last line that has no trailing newline.
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%\#*}"
    line="${${line##[[:space:]]#}%%[[:space:]]#}"
    [[ -z "$line" ]] && continue
    line="${line/#\~/$HOME}"
    SKIP+=("${line//\$HOME/$HOME}")
  done < "$SKIP_FILE"
fi

# Directories that must be private (mode 700). gpg refuses to trust a homedir
# others can write to, and mkdir -p would create it with the default umask.
PRIVATE_DIRS=("$HOME/.gnupg")
zmodload -F zsh/stat b:zstat

# link_one <source> <destination> <label>
# The one place that actually touches the filesystem, so backup and dry-run
# behaviour stays identical for both the home/ convention and links.conf.
link_one() {
  local src="$1" dest="$2" label="$3" saved

  # Checked first: a skipped destination is left exactly as it is, link or not.
  if (( ${SKIP[(Ie)$dest]} )); then
    print "  skip    $label (in ${SKIP_FILE/#$HOME/~})"
    return 0
  fi

  # Report and keep going rather than aborting half-linked; main exits non-zero.
  if [[ ! -e "$src" ]]; then
    print -u2 "  MISSING $label (no such file in the repo: ${src#$REPO/})"
    PROBLEMS=$(( PROBLEMS + 1 ))
    return 0
  fi

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    print "  ok      $label"
    return 0
  fi

  if $DRY_RUN; then
    if [[ -e "$dest" || -L "$dest" ]]; then
      print "  would back up and link  $label"
    else
      print "  would link              $label"
    fi
    return 0
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    # Mirror the path under $HOME inside the backup, so two files with the
    # same basename (two settings.json, say) cannot overwrite each other.
    saved="$BACKUP/${dest#$HOME/}"
    mkdir -p "${saved:h}"
    mv "$dest" "$saved"
    print "  backup  $label -> ${BACKUP/#$HOME/~}"
  fi

  if (( ${PRIVATE_DIRS[(Ie)${dest:h}]} )); then
    (umask 077 && mkdir -p "${dest:h}")
  else
    mkdir -p "${dest:h}"
  fi
  ln -s "$src" "$dest"
  print "  link    $label"
}

link_dir() {
  local dir="$1" src
  # .[!.]* excludes . and ..; (N) yields nothing instead of erroring on no match.
  for src in "$dir"/.[!.]*(N); do
    link_one "$src" "$HOME/${src:t}" "${src:t}"
  done
}

# links.conf format: one "<repo-relative source> <destination>" pair per line.
# Blank lines and # comments are skipped. The source is the first whitespace-
# delimited field; everything after it is the destination, so destinations may
# contain spaces (they do on macOS) without quoting. ~ and $HOME are expanded.
link_manifest() {
  setopt local_options extended_glob
  local file="$1" line src dest label

  [[ -r "$file" ]] || return 0

  while IFS= read -r line; do
    [[ -z "${line//[[:space:]]/}" || "$line" == \#* ]] && continue

    src="${line%%[[:space:]]*}"
    dest="${line#"$src"}"
    dest="${dest##[[:space:]]##}"     # trim the separating whitespace
    dest="${dest%%[[:space:]]##}"     # and any trailing whitespace

    if [[ -z "$dest" ]]; then
      print -u2 "  BAD LINE in ${file#$REPO/}: $line"
      PROBLEMS=$(( PROBLEMS + 1 ))
      continue
    fi

    dest="${dest/#\~/$HOME}"
    dest="${dest//\$HOME/$HOME}"
    label="${dest/#$HOME/~}"

    link_one "${file:h}/$src" "$dest" "$label"
  done < "$file"
}

# Make sure each PRIVATE_DIRS entry that exists is mode 700, even if it was
# created earlier or by something else.
fix_private_modes() {
  local dir mode
  for dir in "${PRIVATE_DIRS[@]}"; do
    [[ -d "$dir" ]] || continue
    zstat -A mode +mode -- "$dir"
    (( (mode & 8#777) == 8#700 )) && continue
    if $DRY_RUN; then
      print "  would chmod 700         ${dir/#$HOME/~} (is $(( [##8] mode & 8#777 )))"
    else
      chmod 700 "$dir"
      print "  chmod   700 ${dir/#$HOME/~}"
    fi
  done
}

# Drop links into this repo whose source has since been deleted. Without this,
# removing a file from home/ leaves a broken symlink in $HOME indefinitely.
# Only the top level of $HOME is scanned - that is where the home/ convention
# puts things, and links.conf destinations are by definition still current.
prune_stale() {
  local dest target
  for dest in "$HOME"/.[!.]*(N@); do
    target="$(readlink "$dest")"
    [[ "$target" == "$REPO"/* ]] || continue   # not ours to remove
    [[ -e "$target" ]] && continue             # source still there

    if $DRY_RUN; then
      print "  would remove stale      ${dest:t}"
    else
      rm "$dest"
      print "  stale   ${dest:t} (source no longer in the repo)"
    fi
  done
}

print "platform: $PLATFORM"
$DRY_RUN && print "DRY RUN - nothing will change"

print "shared (home/):"
link_dir "$REPO/home"
link_manifest "$REPO/links.conf"

print "$PLATFORM ($PLATFORM/home/):"
link_dir "$REPO/$PLATFORM/home"
link_manifest "$REPO/$PLATFORM/links.conf"

fix_private_modes
prune_stale

if (( PROBLEMS )); then
  print -u2 "done, with $PROBLEMS problem(s)."
  exit 1
fi

print "done."
