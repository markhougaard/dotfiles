#!/bin/zsh

# Exit on error
set -e

# Logging functions
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

success() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] SUCCESS: $1"
}

# Error handling
trap 'error "An error occurred. Exiting..."' ERR
trap 'error "Script interrupted. Exiting..."' INT

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    error "This script is only for macOS"
    exit 1
fi

# Check for required dependencies
check_dependencies() {
    log "Checking dependencies..."
    
    # Check for Xcode Command Line Tools
    if ! command -v xcode-select &> /dev/null; then
        log "Installing Xcode Command Line Tools..."
        xcode-select --install || {
            error "Failed to install Xcode Command Line Tools"
            exit 1
        }
    fi
    
    # Check for git
    if ! command -v git &> /dev/null; then
        error "Git is required but not installed"
        exit 1
    fi
}

# Install Homebrew
install_homebrew() {
    log "Installing Homebrew..."
    if ! command -v brew &> /dev/null; then
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            error "Failed to install Homebrew"
            exit 1
        }
        success "Homebrew installed successfully"
    else
        log "Homebrew already installed"
    fi
}

# Install packages via Homebrew
install_packages() {
    log "Installing packages via Homebrew..."
    brew install mas || {
        error "Failed to install mas"
        exit 1
    }
    brew bundle || {
        error "Failed to install packages from Brewfile"
        exit 1
    }
    success "Packages installed successfully"
}

# Install oh-my-zsh
install_oh_my_zsh() {
    log "Installing oh-my-zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" || {
            error "Failed to install oh-my-zsh"
            exit 1
        }
        success "oh-my-zsh installed successfully"
    else
        log "oh-my-zsh already installed"
    fi
}

# Install pure theme
install_pure_theme() {
    log "Installing pure theme..."
    if [ ! -d "$HOME/.zsh/pure" ]; then
        mkdir -p "$HOME/.zsh"
        git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure" || {
            error "Failed to install pure theme"
            exit 1
        }
        success "Pure theme installed successfully"
    else
        log "Pure theme already installed"
    fi
}

# Setup dotfiles
setup_dotfiles() {
    log "Setting up dotfiles..."
    if [ ! -d "$HOME/.dotfiles" ]; then
        git clone --bare https://github.com/marksdk/dotfiles.git $HOME/.dotfiles || {
            error "Failed to clone dotfiles repository"
            exit 1
        }
    fi

    function dot {
        /usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $@
    }

    mkdir -p .dotfiles-backup
    if ! dot checkout; then
        log "Backing up pre-existing dotfiles..."
        dot checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .dotfiles-backup/{}
        dot checkout || {
            error "Failed to checkout dotfiles"
            exit 1
        }
    fi

    dot config status.showUntrackedFiles no
    success "Dotfiles setup completed"
}

# Install iTerm2 profile
install_iterm2_profile() {
    log "Installing iTerm2 profile..."
    if [ ! -d "$HOME/Library/Application Support/iTerm2/DynamicProfiles" ]; then
        mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    fi

    cp "$HOME/.dotfiles/marks.json" "$HOME/Library/Application Support/iTerm2/DynamicProfiles/" || {
        error "Failed to copy iTerm2 profile"
        exit 1
    }
    success "iTerm2 profile installed successfully"
}

# Install zsh plugins
install_zsh_plugins() {
    log "Installing zsh plugins..."
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    for plugin in "zsh-users/zsh-autosuggestions" "agkozak/zsh-z" "zsh-users/zsh-syntax-highlighting"; do
        plugin_name=$(basename $plugin)
        if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
            git clone "https://github.com/$plugin" "$ZSH_CUSTOM/plugins/$plugin_name" || {
                error "Failed to install plugin: $plugin"
                exit 1
            }
        fi
    done
    success "Zsh plugins installed successfully"
}

# Configure macOS settings
configure_macos() {
    log "Configuring macOS settings..."
    if [ -f "$HOME/macos.sh" ]; then
        sh "$HOME/macos.sh" || {
            error "Failed to configure macOS settings"
            exit 1
        }
        success "macOS settings configured successfully"
    else
        error "macos.sh not found"
        exit 1
    fi
}

# Main installation process
main() {
    log "Starting installation process..."
    
    check_dependencies
    install_homebrew
    install_packages
    install_oh_my_zsh
    install_pure_theme
    setup_dotfiles
    install_iterm2_profile
    install_zsh_plugins
    configure_macos
    
    success "Installation completed successfully!"
    log "Please restart your terminal to apply all changes."
}

# Run the installation
main
