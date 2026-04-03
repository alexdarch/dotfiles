#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# =======================
# 1. Install Claude Code
# =======================

if ! command -v claude > /dev/null; then
    echo "WARNING: claude not found. Install it first:"
    echo "  curl -fsSL https://claude.ai/install.sh | sh"
    exit 0
fi

# =======================
# 2. Settings and symlinks
# =======================

echo "Installing claude CLI config..."
mkdir -p ~/.claude

# Generate settings.json from yaml
if command -v yq > /dev/null; then
    yq -o json "$SCRIPT_DIR/settings.yaml" | sed 's|__STATUSLINE_COMMAND__|bash ~/.claude/statusline.sh|g' > "$SCRIPT_DIR/generated-settings.json"
else
    echo "WARNING: yq not found, skipping settings.yaml conversion."
    echo "  Install with: sudo apt-get install -y yq"
fi

# Symlink settings, CLAUDE.md, and statusline
ln -sfn "$SCRIPT_DIR/generated-settings.json" ~/.claude/settings.json
ln -sfn "$SCRIPT_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sfn "$SCRIPT_DIR/statusline/statusline.sh" ~/.claude/statusline.sh
chmod +x "$SCRIPT_DIR/statusline/statusline.sh"

# =======================
# 3. Shared claude CLI config (plugins, MCPs, hooks, skills)
# =======================

echo "Running shared claude configuration..."
bash "$SCRIPT_DIR/configure_claude.sh"

echo "CLAUDE SETUP COMPLETE"
