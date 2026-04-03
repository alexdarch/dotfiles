#!/bin/bash
# Shared claude CLI configuration - called by both install_claude.ps1 and install_claude.sh
# Uses only `claude` CLI commands which work identically on all platforms via Git Bash

set -uo pipefail

if ! command -v claude > /dev/null; then
    echo "WARNING: claude not found, skipping claude CLI configuration"
    exit 0
fi

# =======================
# 1. Configure plugins
# =======================

echo "Configuring plugins..."
claude plugin marketplace add https://github.com/obra/superpowers.git
claude plugin install superpowers@superpowers-dev

# =======================
# 2. Configure MCPs
# =======================

echo "Configuring MCPs..."
# Add MCP servers here, e.g.:
# claude mcp add --transport stdio my-server -- command arg1 arg2

# =======================
# 3. Configure skills
# =======================

echo "Configuring skills..."
# Add skills here

# =======================
# 4. Configure hooks
# =======================

echo "Configuring hooks..."
# Add hooks here

echo "Claude CLI configuration complete."
