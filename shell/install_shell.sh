#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "Installing shell config..."

# Symlink dotfiles
ln -sfn "$SCRIPT_DIR/.profile" "$HOME/.profile"
ln -sfn "$SCRIPT_DIR/.bashrc" "$HOME/.bashrc"
ln -sfn "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"

# Set zsh as default shell (skip if already set)
if [ "$(basename "$SHELL")" != "zsh" ]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    echo "  Default shell changed to zsh (takes effect on next login)"
fi
