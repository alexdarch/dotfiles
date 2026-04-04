#!/bin/bash
set -euo pipefail

echo "Installing system packages and tools..."

# =========================
# 1. System packages
# =========================

echo ""
echo "[1/3] Installing system packages..."
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
echo "[2/3] Installing uv..."
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
echo "[3/3] Installing Claude Code..."
if command -v claude > /dev/null; then
    echo "  Claude Code already installed: $(claude --version)"
else
    curl -fsSL https://claude.ai/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi
