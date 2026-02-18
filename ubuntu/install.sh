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
  git-lfs \
  tmux \
  ripgrep \
  htop \
  jq \
  unzip

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
cp "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"

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
# 11. Install Claude Code for current user
# -----------------------------------------------------------
if [[ ! -f "$HOME/.local/bin/claude" ]] && ! command -v claude &>/dev/null; then
  echo "==> Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "==> Claude Code already installed, skipping."
fi

# -----------------------------------------------------------
# 12. Set up optional dev user with Claude Code + tmux
# -----------------------------------------------------------
echo ""
echo "==> Dev user setup"
echo "    Optionally create a non-root dev user with Claude Code, tmux, and"
echo "    the cc/ccw helpers. The user will share your SSH key and have sudo"
echo "    and docker access."
read -rp "    Dev username to create (press Enter to skip): " DEV_USER || DEV_USER=""

if [[ -n "${DEV_USER:-}" ]]; then
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "  -> Skipping user creation: script must be run as root."
    echo "     Re-run as root, or create '${DEV_USER}' manually and re-run."
  else
    # Create user if it doesn't exist yet
    if ! id "${DEV_USER}" &>/dev/null; then
      echo "==> Creating user '${DEV_USER}'..."
      adduser --disabled-password --gecos "" "${DEV_USER}"
      usermod -aG sudo "${DEV_USER}"
      usermod -aG docker "${DEV_USER}" 2>/dev/null || true
      mkdir -p "/home/${DEV_USER}/.ssh"
      cp /root/.ssh/authorized_keys "/home/${DEV_USER}/.ssh/" 2>/dev/null || true
      chown -R "${DEV_USER}:${DEV_USER}" "/home/${DEV_USER}/.ssh"
      chmod 700 "/home/${DEV_USER}/.ssh"
      chmod 600 "/home/${DEV_USER}/.ssh/authorized_keys" 2>/dev/null || true
      echo "  -> User '${DEV_USER}' created with sudo + docker access."
      echo "  -> SSH keys copied from root."
    else
      echo "==> User '${DEV_USER}' already exists, skipping creation."
    fi

    # Install oh-my-zsh for the dev user
    if [[ ! -d "/home/${DEV_USER}/.oh-my-zsh" ]]; then
      echo "==> Installing oh-my-zsh for '${DEV_USER}'..."
      su - "${DEV_USER}" -c \
        'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
    fi

    # Install Pure prompt for the dev user
    if [[ ! -d "/home/${DEV_USER}/.zsh/pure" ]]; then
      echo "==> Installing Pure prompt for '${DEV_USER}'..."
      su - "${DEV_USER}" -c \
        'mkdir -p ~/.zsh && git clone https://github.com/sindresorhus/pure.git ~/.zsh/pure'
    fi

    # Install zsh plugins for the dev user
    _install_plugin() {
      local user="$1" name="$2" url="$3"
      local pdir="/home/${user}/.oh-my-zsh/custom/plugins/${name}"
      if [[ ! -d "$pdir" ]]; then
        echo "  -> Installing ${name}..."
        su - "${user}" -c "git clone '${url}' '${pdir}'"
      fi
    }
    echo "==> Installing zsh plugins for '${DEV_USER}'..."
    _install_plugin "${DEV_USER}" "zsh-autosuggestions" \
      "https://github.com/zsh-users/zsh-autosuggestions"
    _install_plugin "${DEV_USER}" "zsh-z" \
      "https://github.com/agkozak/zsh-z"
    _install_plugin "${DEV_USER}" "zsh-syntax-highlighting" \
      "https://github.com/zsh-users/zsh-syntax-highlighting.git"

    # Copy dotfiles configs for the dev user
    echo "==> Copying dotfiles for '${DEV_USER}'..."
    cp "${SCRIPT_DIR}/.zshrc"    "/home/${DEV_USER}/.zshrc"
    cp "${SCRIPT_DIR}/.gitconfig" "/home/${DEV_USER}/.gitconfig"
    cp "${SCRIPT_DIR}/.zprofile"  "/home/${DEV_USER}/.zprofile"
    cp "${SCRIPT_DIR}/.tmux.conf" "/home/${DEV_USER}/.tmux.conf"
    chown "${DEV_USER}:${DEV_USER}" \
      "/home/${DEV_USER}/.zshrc" \
      "/home/${DEV_USER}/.gitconfig" \
      "/home/${DEV_USER}/.zprofile" \
      "/home/${DEV_USER}/.tmux.conf"

    # Install Claude Code for the dev user
    echo "==> Installing Claude Code for '${DEV_USER}'..."
    su - "${DEV_USER}" -c 'curl -fsSL https://claude.ai/install.sh | bash'

    # Set default shell to zsh
    chsh -s "$(command -v zsh)" "${DEV_USER}"

    echo ""
    echo "  -> '${DEV_USER}' is ready."
    echo "     Next steps for '${DEV_USER}':"
    echo "       1. ssh ${DEV_USER}@<server-ip>"
    echo "       2. claude          — authenticate (one-time)"
    echo "       3. cc              — start Claude Code in a persistent tmux session"
    echo "       Ctrl+A, D          — detach (session keeps running)"
  fi
fi

# -----------------------------------------------------------
# Done
# -----------------------------------------------------------
echo ""
echo "==> Setup complete!"
echo "    - Log out and back in (or run 'zsh') to start using your new shell."
echo "    - Your old dotfiles (if any) were backed up to ~/.dotfiles-backup/"
echo "    - Run 'claude' once to authenticate, then use 'cc' to start coding."
