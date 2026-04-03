#!/bin/bash
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

echo "Linux not fully setup yet - skipping symlinks"

# Install git config
"$DOTFILES_DIR/git/git_install.sh"

# Install IDE extensions
"$DOTFILES_DIR/ide/install_ide.sh"