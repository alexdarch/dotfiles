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

# https://github.com/travisvn/awesome-claude-skills

echo "Configuring plugins..."

# Superpowers (brainstorming, code review, plans, etc.)
claude plugin marketplace add https://github.com/obra/superpowers.git
claude plugin install superpowers@superpowers-dev

# Anthropic skills marketplace
claude plugin marketplace add https://github.com/anthropics/skills.git

# MCP builder + skill creator
claude plugin install example-skills@anthropic-agent-skills

# Ralph loop (autonomous iteration)
claude plugin install ralph-loop@claude-plugins-official

# Frontend design (production-grade frontend interfaces)
claude plugin install frontend-design@claude-plugins-official

# Context7 (documentation lookup MCP, community-managed)
claude plugin install context7@claude-plugins-official

# Code review (multi-agent PR review)
claude plugin install code-review@claude-plugins-official

# Code simplifier (refactor for clarity/consistency)
claude plugin install code-simplifier@claude-plugins-official

# =======================
# 2. Configure MCPs
# =======================

echo "Configuring MCPs..."

# Note: context7 MCP is provided by the context7@claude-plugins-official plugin above.

# GitHub MCP (uses GITHUB_PERSONAL_ACCESS_TOKEN env var from .profile)
claude mcp add --scope user github -- npx -y @modelcontextprotocol/server-github

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
