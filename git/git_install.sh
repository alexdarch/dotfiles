#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# =========================
# 1. Git config
# =========================

ln -sfn "$SCRIPT_DIR/.gitconfig-linux" "$HOME/.gitconfig"

# =========================
# 2. GitHub SSH setup
# =========================

SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ -f "$SSH_KEY" ]]; then
    echo "SSH key already exists at $SSH_KEY -skipping generation"
else
    echo "Generating SSH key..."
    mkdir -p "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "alex.darch@btinternet.com" -f "$SSH_KEY"

    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY"

    # Copy public key to clipboard
    if command -v xclip &>/dev/null; then
        xclip -selection clipboard < "$SSH_KEY.pub"
        echo "Public key copied to clipboard."
    elif command -v pbcopy &>/dev/null; then
        pbcopy < "$SSH_KEY.pub"
        echo "Public key copied to clipboard."
    else
        echo "Public key:"
        cat "$SSH_KEY.pub"
    fi

    echo "Add it to GitHub: https://github.com/settings/ssh/new"
    echo ""
    read -rp "Press Enter after adding the key to GitHub"
fi

# Verify GitHub connection
echo "Testing GitHub SSH connection..."
ssh -T git@github.com 2>&1 || true
