#!/bin/bash
set -euo pipefail

# Ubuntu server dotfiles install script
# Usage: bash ubuntu/install.sh

DOTFILES_REPO="https://github.com/marksdk/dotfiles.git"

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
# 8. Set up bare-repo dotfiles
# -----------------------------------------------------------
if [ ! -d "$HOME/.dotfiles" ]; then
  echo "==> Setting up bare-repo dotfiles..."
  git clone --bare "$DOTFILES_REPO" "$HOME/.dotfiles"

  function dot {
    /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
  }

  # Back up any conflicting files
  mkdir -p "$HOME/.dotfiles-backup"
  if ! dot checkout 2>/dev/null; then
    echo "  -> Backing up pre-existing dotfiles..."
    dot checkout 2>&1 | grep -E "^\s+" | awk '{print $1}' | xargs -I{} mv "$HOME/{}" "$HOME/.dotfiles-backup/{}"
    dot checkout
  fi

  dot config --local status.showUntrackedFiles no
  echo "  -> Dotfiles checked out successfully."
else
  echo "==> Dotfiles bare repo already exists, skipping clone."
fi

# -----------------------------------------------------------
# 9. Copy Ubuntu-specific configs into place
# -----------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Copying Ubuntu-specific configs..."
cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
cp "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
cp "$SCRIPT_DIR/.zprofile" "$HOME/.zprofile"

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
echo "    - Your old dotfiles (if any) were backed up to ~/.dotfiles-backup/"
