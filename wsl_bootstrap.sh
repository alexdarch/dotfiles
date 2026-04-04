#!/bin/bash
set -euo pipefail

echo "==========================="
echo " WSL2 Bootstrap"
echo "==========================="

# =========================
# 1. System packages
# =========================

echo ""
echo "[1/5] Installing system packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    build-essential \
    bubblewrap \
    socat \
    git \
    curl \
    unzip \
    openssh-client

# =========================
# 2. Install uv (Python toolchain)
# =========================

echo ""
echo "[2/5] Installing uv..."
if command -v uv > /dev/null; then
    echo "  uv already installed: $(uv --version)"
else
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    echo "  Installed: $(uv --version)"
fi

# =========================
# 3. Install Claude Code
# =========================

echo ""
echo "[3/5] Installing Claude Code..."
if command -v claude > /dev/null; then
    echo "  Claude Code already installed: $(claude --version)"
else
    curl -fsSL https://claude.ai/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

# =========================
# 4. Run dotfiles install.sh
# =========================

echo ""
echo "[4/5] Running dotfiles installer..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
bash "$SCRIPT_DIR/install.sh"

# =========================
# 5. Switch dotfiles remote to SSH (if cloned via HTTPS)
# =========================

echo ""
echo "[5/5] Checking dotfiles git remote..."
CURRENT_REMOTE=$(git -C "$SCRIPT_DIR" remote get-url origin 2>/dev/null || echo "")
if [[ "$CURRENT_REMOTE" == https://* ]]; then
    SSH_REMOTE=$(echo "$CURRENT_REMOTE" | sed 's|https://github.com/|git@github.com:|')
    echo "  Switching remote from HTTPS to SSH:"
    echo "    $CURRENT_REMOTE -> $SSH_REMOTE"
    git -C "$SCRIPT_DIR" remote set-url origin "$SSH_REMOTE"
else
    echo "  Remote already using SSH."
fi

echo ""
echo "==========================="
echo " Setup complete!"
echo "==========================="
echo ""
echo "  Access WSL files from Windows Explorer:"
echo "    \\\\wsl\$\\Ubuntu\\home\\$(whoami)"
echo ""
echo "  Open VS Code into WSL:"
echo "    code ~/source/<project>"
echo "    (install the 'WSL' extension in VS Code if not already)"
echo ""
echo "  Run Claude Code:  claude"
echo "  Bubblewrap sandbox is active."
echo "==========================="
