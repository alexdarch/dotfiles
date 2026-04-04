#!/bin/bash
set -euo pipefail

echo "Installing system packages and tools..."

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
    openssh-client \
    locales \
    zsh \
    fzf

# Generate en_US.UTF-8 locale if missing
if ! locale -a 2>/dev/null | grep -q "en_US.utf8"; then
    echo "  Generating en_US.UTF-8 locale..."
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8
fi

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
# 4. Install starship prompt
# =========================

echo ""
echo "[4/5] Installing starship..."
if command -v starship > /dev/null; then
    echo "  starship already installed: $(starship --version)"
else
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo "  Installed: $(starship --version)"
fi

# =========================
# 5. Install zoxide
# =========================

echo ""
echo "[5/5] Installing zoxide..."
if command -v zoxide > /dev/null; then
    echo "  zoxide already installed: $(zoxide --version)"
else
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    echo "  Installed: $(zoxide --version)"
fi
