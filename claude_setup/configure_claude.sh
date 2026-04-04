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

# Document handling (docx, pdf, pptx, xlsx)
claude plugin install document-skills@anthropic-agent-skills

# MCP builder + skill creator
claude plugin install example-skills@anthropic-agent-skills

# Ralph loop (autonomous iteration)
claude plugin install ralph-loop@claude-plugins-official

# =======================
# 2. Configure MCPs
# =======================

echo "Configuring MCPs..."

# Context7 - documentation finder
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp

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
