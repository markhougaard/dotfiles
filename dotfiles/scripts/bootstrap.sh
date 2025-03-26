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

# Parse command line arguments
DRY_RUN=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --dry-run) DRY_RUN=true ;;
        *) error "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Create necessary directories
create_directories() {
    log "Creating directory structure..."
    
    if [ "$DRY_RUN" = true ]; then
        log "Would create: $HOME/.dotfiles/{scripts,configs,apps}"
        log "Would create: $HOME/.dotfiles-backup"
    else
        # Create main directories
        mkdir -p "$HOME/.dotfiles/{scripts,configs,apps}"
        
        # Create backup directory
        mkdir -p "$HOME/.dotfiles-backup"
    fi
    
    success "Directory structure created"
}

# Setup symlinks
setup_symlinks() {
    log "Setting up symlinks..."
    
    if [ "$DRY_RUN" = true ]; then
        log "Would create symlink: $HOME/Brewfile -> $HOME/dotfiles/apps/Brewfile"
        log "Would check and update: $HOME/.zshrc"
        log "Would check and update: $HOME/.gitignore"
    else
        # Create symlink for Brewfile
        ln -sf "$HOME/dotfiles/apps/Brewfile" "$HOME/Brewfile"
        
        # Add dot alias to .zshrc if not already present
        if ! grep -q "alias dot=" "$HOME/.zshrc"; then
            echo "alias dot='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> "$HOME/.zshrc"
        fi
        
        # Add .dotfiles to .gitignore if not already present
        if ! grep -q ".dotfiles" "$HOME/.gitignore"; then
            echo ".dotfiles" >> "$HOME/.gitignore"
        fi
    fi
    
    success "Symlinks created"
}

# Clone dotfiles repository
clone_dotfiles() {
    log "Cloning dotfiles repository..."
    
    if [ "$DRY_RUN" = true ]; then
        log "Would clone: https://github.com/markhougaard/dotfiles.git to $HOME/.dotfiles"
    else
        if [ ! -d "$HOME/.dotfiles" ]; then
            git clone --bare https://github.com/markhougaard/dotfiles.git "$HOME/.dotfiles" || {
                error "Failed to clone dotfiles repository"
                exit 1
            }
            success "Dotfiles repository cloned"
        else
            log "Dotfiles repository already exists"
        fi
    fi
}

# Main bootstrap process
main() {
    log "Starting bootstrap process..."
    if [ "$DRY_RUN" = true ]; then
        log "DRY RUN MODE - No changes will be made"
    fi
    
    create_directories
    setup_symlinks
    clone_dotfiles
    
    success "Bootstrap completed successfully!"
    if [ "$DRY_RUN" = true ]; then
        log "This was a dry run. No changes were made."
    else
        log "Now you can run install.sh to complete the setup."
    fi
}

# Run the bootstrap
main 