#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "Installing shell config..."

# Copy dotfiles (not symlink — bubblewrap can't resolve symlinks for bind mounts)
cp "$SCRIPT_DIR/.profile" "$HOME/.profile"
cp "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"
cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

# Set zsh as default shell (skip if already set)
if [ "$(basename "$SHELL")" != "zsh" ]; then
    echo "Setting zsh as default shell..."
    sudo chsh -s "$(which zsh)" "$USER"
    echo "  Default shell changed to zsh (takes effect on next login)"
fi
