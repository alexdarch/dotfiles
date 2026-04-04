#!/bin/bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# =======================
# 1. Install Claude Code
# =======================

if ! command -v claude > /dev/null; then
    echo "WARNING: claude not found. Install it first:"
    curl -fsSL https://claude.ai/install.sh | bash
fi

# =======================
# 2. Settings and symlinks
# =======================

echo "Installing claude CLI config..."
mkdir -p ~/.claude

# Generate settings.json from yaml using uv + pyyaml
uv run --with pyyaml --no-project python -c "
import yaml, json, sys, re
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)

# Remove Windows-only env var
data.get('env', {}).pop('CLAUDE_CODE_USE_POWERSHELL_TOOL', None)

j = json.dumps(data, indent=2)

# Platform-specific replacements
j = j.replace('__STATUSLINE_COMMAND__', 'bash ~/.claude/statusline.sh')
j = j.replace('__TEMP_DIR__', '/tmp')

# Remove lines containing the Windows-only AppData placeholder
j = '\n'.join(l for l in j.splitlines() if '__APPDATA_DIR__' not in l)

# Fix any trailing commas left by removed lines (invalid JSON)
j = re.sub(r',(\s*[\]\}])', r'\1', j)

with open(sys.argv[2], 'w', encoding='utf-8', newline='\n') as f:
    f.write(j + '\n')
" "$SCRIPT_DIR/settings.yaml" "$SCRIPT_DIR/generated-settings.json"

# Build skills.yaml from all SKILL.md files under ~/.claude
echo "Building skills.yaml..."
uv run --no-project --script "$SCRIPT_DIR/skills/build_skills_yaml.py" ~/.claude -o ~/.claude/skills.yaml

# Copy settings (not symlink — bubblewrap can't resolve symlinks for its own config)
cp "$SCRIPT_DIR/generated-settings.json" ~/.claude/settings.json
# Copy files (not symlink — bubblewrap can't resolve symlinks for bind mounts)
cp "$SCRIPT_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
cp "$SCRIPT_DIR/statusline/statusline.sh" ~/.claude/statusline.sh
# Copy hooks directory contents (not symlink — bubblewrap can't resolve symlinks)
rm -rf ~/.claude/hooks
mkdir -p ~/.claude/hooks
cp -r "$SCRIPT_DIR/hooks/"* ~/.claude/hooks/ 2>/dev/null || true
chmod +x "$SCRIPT_DIR/statusline/statusline.sh"

# =======================
# 3. Shared claude CLI config (plugins, MCPs, hooks, skills)
# =======================

echo "Running shared claude configuration..."
bash "$SCRIPT_DIR/configure_claude.sh"

echo "CLAUDE SETUP COMPLETE"
