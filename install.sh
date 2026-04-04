#!/bin/bash
set -uo pipefail

echo "==========================="
echo " Dotfiles Install"
echo "==========================="

# Ensure ~/.local/bin is on PATH (where uv, claude, etc. install to)
export PATH="$HOME/.local/bin:$PATH"
grep -qF '/.local/bin' ~/.bashrc 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

# Install system packages, uv, claude
"$DOTFILES_DIR/packages/install_packages.sh"

# Install shell config (zsh, bashrc, profile)
"$DOTFILES_DIR/shell/install_shell.sh"

# Install git config
"$DOTFILES_DIR/git/git_install.sh"

# Install IDE extensions
"$DOTFILES_DIR/ide/install_ide.sh"

# Install Claude Code config
"$DOTFILES_DIR/claude_setup/install_claude.sh"

# Switch dotfiles remote to SSH (if cloned via HTTPS)
echo ""
echo "Checking dotfiles git remote..."
CURRENT_REMOTE=$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || echo "")
if [[ "$CURRENT_REMOTE" == https://* ]]; then
    SSH_REMOTE=$(echo "$CURRENT_REMOTE" | sed 's|https://github.com/|git@github.com:|')
    echo "  Switching remote from HTTPS to SSH:"
    echo "    $CURRENT_REMOTE -> $SSH_REMOTE"
    git -C "$DOTFILES_DIR" remote set-url origin "$SSH_REMOTE"
else
    echo "  Remote already using SSH."
fi

echo ""
echo "==========================="
echo " Setup complete!"
echo "==========================="
