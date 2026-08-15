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

link_dir() {
  local dir="$1" src name dest
  # .[!.]* excludes . and ..; (N) yields nothing instead of erroring on no match.
  for src in "$dir"/.[!.]*(N); do
    name="${src:t}"
    dest="$HOME/$name"

    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      print "  ok      $name"
      continue
    fi

    if $DRY_RUN; then
      if [[ -e "$dest" || -L "$dest" ]]; then
        print "  would back up and link  $name"
      else
        print "  would link             $name"
      fi
      continue
    fi

    if [[ -e "$dest" || -L "$dest" ]]; then
      mkdir -p "$BACKUP"
      mv "$dest" "$BACKUP/$name"
      print "  backup  $name -> ${BACKUP/#$HOME/~}"
    fi

    ln -s "$src" "$dest"
    print "  link    $name"
  done
}

print "platform: $PLATFORM"
$DRY_RUN && print "DRY RUN - nothing will change"

print "shared (home/):"
link_dir "$REPO/home"

print "$PLATFORM ($PLATFORM/home/):"
link_dir "$REPO/$PLATFORM/home"

print "done."
