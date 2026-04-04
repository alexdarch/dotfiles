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

# Generate settings.json from yaml using uv + pyyaml
uv run --with pyyaml --no-project python -c "
import yaml, json, sys
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
j = json.dumps(data, indent=2)
j = j.replace('__STATUSLINE_COMMAND__', 'bash ~/.claude/statusline.sh')
with open(sys.argv[2], 'w', encoding='utf-8', newline='\n') as f:
    f.write(j + '\n')
" "$SCRIPT_DIR/settings.yaml" "$SCRIPT_DIR/generated-settings.json"

# Build skills.yaml from all SKILL.md files under ~/.claude
echo "Building skills.yaml..."
uv run --no-project --script "$SCRIPT_DIR/skills/build_skills_yaml.py" ~/.claude -o ~/.claude/skills.yaml

# Symlink settings, CLAUDE.md, statusline, and hooks dir
ln -sfn "$SCRIPT_DIR/generated-settings.json" ~/.claude/settings.json
ln -sfn "$SCRIPT_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
ln -sfn "$SCRIPT_DIR/statusline/statusline.sh" ~/.claude/statusline.sh
ln -sfn "$SCRIPT_DIR/hooks" ~/.claude/hooks
chmod +x "$SCRIPT_DIR/statusline/statusline.sh"

# =======================
# 3. Shared claude CLI config (plugins, MCPs, hooks, skills)
# =======================

echo "Running shared claude configuration..."
bash "$SCRIPT_DIR/configure_claude.sh"

echo "CLAUDE SETUP COMPLETE"
