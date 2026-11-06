#!/bin/bash
set -euo pipefail

# Ubuntu server dotfiles install script
# Usage: git clone https://github.com/markhougaard/dotfiles.git ~/dotfiles
#        bash ~/dotfiles/ubuntu/install.sh        (SKIP_APT=1 to skip apt)
#
# On Ubuntu, ~/dotfiles is a normal clone and the files in ubuntu/ are
# SYMLINKED into $HOME, so editing ~/.zshrc edits the repo: commit from
# ~/dotfiles. (The bare-repo pattern is macOS-only: it would check the Mac
# files out over the server ones.)

# -----------------------------------------------------------
# 1. Check we're on Linux
# -----------------------------------------------------------
if [ "$(uname)" != "Linux" ]; then
  echo "Error: This script is intended for Linux systems only."
  exit 1
fi

echo "==> Starting Ubuntu dotfiles setup..."

# -----------------------------------------------------------
# 2. Install essential packages via apt
# -----------------------------------------------------------
if [ "${SKIP_APT:-}" != "1" ]; then
  echo "==> Installing essential packages..."
  sudo apt update
  sudo apt install -y \
    zsh \
    git \
    curl \
    wget \
    vim \
    build-essential \
    gpg \
    git-lfs
else
  echo "==> Skipping apt install (SKIP_APT=1)."
fi

# -----------------------------------------------------------
# 3. Install oh-my-zsh
# -----------------------------------------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing oh-my-zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "==> oh-my-zsh already installed, skipping."
fi

# -----------------------------------------------------------
# 4. Install Pure prompt
# -----------------------------------------------------------
if [ ! -d "$HOME/.zsh/pure" ]; then
  echo "==> Installing Pure prompt..."
  mkdir -p "$HOME/.zsh"
  git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
else
  echo "==> Pure prompt already installed, skipping."
fi

# -----------------------------------------------------------
# 5. Install zsh plugins
# -----------------------------------------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "==> Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "==> zsh-autosuggestions already installed, skipping."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-z" ]; then
  echo "==> Installing zsh-z..."
  git clone https://github.com/agkozak/zsh-z "$ZSH_CUSTOM/plugins/zsh-z"
else
  echo "==> zsh-z already installed, skipping."
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "==> Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "==> zsh-syntax-highlighting already installed, skipping."
fi

# -----------------------------------------------------------
# 6. Install NVM
# -----------------------------------------------------------
if [ ! -d "$HOME/.nvm" ]; then
  echo "==> Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
  echo "==> NVM already installed, skipping."
fi

# -----------------------------------------------------------
# 7. Install diff-so-fancy
# -----------------------------------------------------------
if ! command -v diff-so-fancy &>/dev/null; then
  echo "==> Installing diff-so-fancy..."
  # Load NVM so we can use npm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  if command -v npm &>/dev/null; then
    npm install -g diff-so-fancy
  else
    echo "  -> Installing Node LTS first..."
    nvm install --lts
    npm install -g diff-so-fancy
  fi
else
  echo "==> diff-so-fancy already installed, skipping."
fi

# -----------------------------------------------------------
# 8. Symlink Ubuntu configs into $HOME
# -----------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

echo "==> Linking Ubuntu configs from $SCRIPT_DIR..."
for f in .zshrc .zprofile .gitconfig .tmux.conf; do
  src="$SCRIPT_DIR/$f"; dst="$HOME/$f"
  if [ "$(readlink -f "$dst" 2>/dev/null)" = "$src" ]; then
    echo "  -> $f already linked"
    continue
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/$f"
    echo "  -> backed up existing $f to $BACKUP/"
  fi
  ln -s "$src" "$dst"
  echo "  -> linked $f"
done

# -----------------------------------------------------------
# 9. Retire the old bare repo, if an earlier version made one
# -----------------------------------------------------------
if [ -d "$HOME/.dotfiles" ] && [ "$(git --git-dir="$HOME/.dotfiles" rev-parse --is-bare-repository 2>/dev/null)" = "true" ]; then
  echo "==> Found old bare repo at ~/.dotfiles (no longer used on Ubuntu)."
  echo "    Remove it once you're happy: rm -rf ~/.dotfiles"
fi

# -----------------------------------------------------------
# 10. Change default shell to zsh
# -----------------------------------------------------------
if [ "$SHELL" != "$(command -v zsh)" ]; then
  echo "==> Changing default shell to zsh..."
  chsh -s "$(command -v zsh)"
else
  echo "==> Default shell is already zsh."
fi

# -----------------------------------------------------------
# Done
# -----------------------------------------------------------
echo ""
echo "==> Setup complete!"
echo "    - Log out and back in (or run 'zsh') to start using your new shell."
echo "    - Replaced files (if any) were backed up under ~/.dotfiles-backup/"
echo "    - Edit configs in place, then commit from ~/dotfiles."
