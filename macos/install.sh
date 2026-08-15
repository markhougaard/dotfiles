#!/usr/bin/env zsh
#
# macOS setup. Run after cloning the repo:
#
#   git clone https://github.com/markhougaard/dotfiles.git ~/dotfiles
#   ~/dotfiles/macos/install.sh
#
# Idempotent: every step checks before acting, so re-running is safe.

set -euo pipefail

REPO="${0:A:h:h}"

log()     { print "[$(date +'%Y-%m-%d %H:%M:%S')] $1" ; }
error()   { print -u2 "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" ; }
success() { print "[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $1" ; }

trap 'error "An error occurred. Exiting..."' ERR
trap 'error "Script interrupted. Exiting..."' INT

if [[ "$(uname)" != "Darwin" ]]; then
  error "This script is only for macOS. For a server, use ubuntu/install.sh."
  exit 1
fi

check_dependencies() {
  log "Checking dependencies..."
  if ! xcode-select -p &>/dev/null; then
    log "Installing Xcode Command Line Tools..."
    xcode-select --install
    log "Re-run this script once the Command Line Tools finish installing."
    exit 0
  fi
  if ! command -v git &>/dev/null; then
    error "Git is required but not installed"
    exit 1
  fi
}

install_homebrew() {
  if command -v brew &>/dev/null; then
    log "Homebrew already installed"
    return
  fi
  log "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
  success "Homebrew installed"
}

install_packages() {
  # The Brewfile's `mas` lines need you signed into the App Store. Apple removed
  # programmatic sign-in (and mas 7 has no way to report sign-in status), so this
  # is the one step of a new-Mac setup that can't be automated.
  log "The Brewfile installs App Store apps, which requires being signed in."
  print -n "Sign into the App Store now, then press Enter to continue "
  read -r _

  log "Installing packages from macos/Brewfile..."
  brew bundle --file="$REPO/macos/Brewfile"
  success "Packages installed"
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "oh-my-zsh already installed"
    return
  fi
  log "Installing oh-my-zsh..."
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "oh-my-zsh installed"
}

install_pure_prompt() {
  if [[ -d "$HOME/.zsh/pure" ]]; then
    log "Pure prompt already installed"
    return
  fi
  log "Installing Pure prompt..."
  mkdir -p "$HOME/.zsh"
  git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
  success "Pure prompt installed"
}

install_zsh_plugins() {
  log "Installing zsh plugins..."
  local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local plugin name
  for plugin in zsh-users/zsh-autosuggestions agkozak/zsh-z zsh-users/zsh-syntax-highlighting; do
    name="${plugin##*/}"
    if [[ -d "$custom/plugins/$name" ]]; then
      log "  $name already installed"
    else
      git clone "https://github.com/$plugin" "$custom/plugins/$name"
    fi
  done
  success "Zsh plugins installed"
}

link_dotfiles() {
  log "Linking dotfiles..."
  "$REPO/link.sh" macos
  success "Dotfiles linked"
}

install_iterm2_profile() {
  log "Installing iTerm2 profile..."
  local dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
  mkdir -p "$dir"
  # Copied, not symlinked: iTerm2's DynamicProfiles watcher is unreliable with symlinks.
  cp "$REPO/macos/iterm2-marks.json" "$dir/"
  success "iTerm2 profile installed"
}

configure_macos() {
  print ""
  log "macos/defaults.sh sets ~150 system preferences. It uses sudo, clears the"
  log "Dock, changes nvram, and needs a logout to fully apply."
  print -n "Run it now? [y/N] "
  local reply
  read -r reply
  if [[ "$reply" == [yY] ]]; then
    zsh "$REPO/macos/defaults.sh"
    success "macOS defaults applied - log out and back in to finish"
  else
    log "Skipped. Run it later with: zsh $REPO/macos/defaults.sh"
  fi
}

main() {
  log "Starting macOS setup..."
  check_dependencies
  install_homebrew
  install_packages
  install_oh_my_zsh
  install_pure_prompt
  install_zsh_plugins
  link_dotfiles
  install_iterm2_profile
  configure_macos
  success "Setup complete. Restart your terminal."
}

main
