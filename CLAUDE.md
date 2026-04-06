# Dotfiles

Cross-platform dotfiles for WSL2 (primary), Windows, and Linux. Manages config for shell, git, IDE, and Claude Code.
If you are making changes to this repo then it is this CLAUDE.md (./CLAUDE.md) you should change.
The ./claude_setup/CLAUDE.md is the global one copied to ~/.claude/CLAUDE.md. DO NOT CHANGE THIS UNLESS SPECIFICALLY ASKED.

## Structure

```
install.sh           # Single entry point — packages, shell, git, IDE, claude setup, remote switch
install.ps1          # Windows entry point - installs WSL2 (previous native setup commented out)

packages/
  install_packages.sh # System packages (apt), uv, Claude Code, starship, zoxide, eza, ripgrep, fzf

git/
  .gitconfig-linux   # Linux/WSL git config (copied to ~/.gitconfig)
  .gitconfig-windows # Windows git config (symlinked to ~/.gitconfig)
  git_install.ps1    # Windows: symlinks .gitconfig-windows + GitHub SSH setup
  git_install.sh     # Linux: copies .gitconfig-linux to ~/.gitconfig + GitHub SSH setup

ide/
  vscode_settings.json    # VS Code user settings (symlinked to Code/User/settings.json)
  vscode_extensions.txt   # Extension list, supports pinned versions (e.g. ext@1.0.0)
  install_ide.ps1         # Windows: symlinks settings, installs extensions
  install_ide.sh          # Linux: same

shell/
  .profile           # Shared env vars, PATH, aliases (sourced by .bashrc and .zshrc)
  .bashrc            # Bash-specific: history, completions, fzf
  .zshrc             # Zsh-specific: zinit, plugins (syntax highlighting, autosuggestions, completions), fzf
  prompt.bash        # Bash prompt: user@host: path [git] $ (uses __git_ps1)
  prompt.zsh         # Zsh prompt: user@host: path [git] $ (uses __git_ps1)
  install_shell.sh   # Linux: copies shell configs, sets zsh as default
  profile.ps1        # PowerShell profile (symlinked to WindowsPowerShell dir)

claude_setup/
  settings.yaml           # Source of truth for Claude Code settings (has comments)
  generate_settings.py    # Generates settings.json from yaml (takes 'linux' or 'windows' arg)
  generated-settings.json # Auto-generated from yaml - do NOT edit directly
  CLAUDE.md               # Global Claude Code instructions (copied to ~/.claude/)
  install_claude.ps1      # Windows: converts yaml, symlinks, runs shared config
  install_claude.sh       # Linux: same
  configure_claude.sh     # Shared claude CLI commands (plugins, MCPs, hooks, skills)
  statusline/
    statusline.ps1        # Windows statusline script
    statusline.sh         # Linux statusline script (uses uv/python for JSON parsing)
  hooks/                  # Copied to ~/.claude/hooks
    event-logger.py       # Logs hook events to ~/.claude/hooks-logs/
    encourage_skill_usage.py  # UserPromptSubmit hook: suggests relevant skills via Haiku
  skills/
    build_skills_yaml.py  # Scans ~/.claude for SKILL.md files, writes ~/.claude/skills.yaml
    test_build_skills_yaml.py  # Tests for build_skills_yaml.py
```

## Conventions

- Primary dev environment is WSL2; `install.ps1` just bootstraps WSL
- `install.sh` is the single entry point: installs packages/tools, then configures shell, git, IDE, and Claude
- Each subdirectory has its own install script in both `.ps1` (Windows) and `.sh` (Linux) variants
- Shell setup: zsh is default, bash is configured as fallback. Shared env/aliases in `.profile`, shell-specific config in `.bashrc`/`.zshrc`, prompts in `prompt.bash`/`prompt.zsh`
- Tools installed: docker, uv, fzf (fuzzy finder), zoxide (smart cd), eza (modern ls), ripgrep (fast grep), starship (prompt, available but not currently used)
- `settings.yaml` uses placeholders replaced at install time per platform:
  - `__STATUSLINE_COMMAND__` → statusline invocation (bash vs powershell)
  - `__TEMP_DIR__` → `/tmp` (Linux) or `//tmp` (Windows)
  - `__APPDATA_DIR__` → `~/AppData/Local` (Windows only, removed on Linux)
  - `CLAUDE_CODE_USE_POWERSHELL_TOOL` env var is removed on Linux
- `generated-settings.json` is gitignored output - always regenerate from `settings.yaml`
- Shared cross-platform logic (claude CLI commands) goes in `.sh` files called via `bash` from both platforms

## MCP Servers

- **GitHub**: `@modelcontextprotocol/server-github` (stdio, user scope). Uses `GITHUB_PERSONAL_ACCESS_TOKEN` env var set dynamically in `.profile` via `gh auth token`. Do NOT use `@anthropic/github-mcp-server` or `github@claude-plugins-official` — those require a GitHub Copilot subscription.
- **Context7**: `@upstash/context7-mcp` (stdio, user scope). Documentation lookup for libraries/frameworks.
- **IDE**: Built-in MCP for IDE integration (VS Code / JetBrains).
- **claude.ai managed MCPs** (Slack, Notion, Linear, etc.): Built-in Anthropic integrations served via `mcp-proxy.anthropic.com`. Cannot be removed or disabled via CLI — they're managed server-side. Harmless if unused (just show "needs authentication" in `claude mcp list`).
- MCP tool permissions are granted via wildcard patterns in `settings.yaml` (e.g. `mcp__github__*`)
- MCPs are configured in `configure_claude.sh` via `claude mcp add --scope user`

## Known Issues / Gotchas

- **All dotfiles in `~` and `~/.claude` must be regular files, not symlinks.** Bubblewrap (bwrap) sandbox can't resolve symlinks when setting up bind mounts, causing all Bash commands to fail. All Linux install scripts use `cp` not `ln -sfn`. This applies to: `~/.bashrc`, `~/.zshrc`, `~/.profile`, `~/.gitconfig`, `~/.claude/settings.json`, `~/.claude/CLAUDE.md`, `~/.claude/statusline.sh`, `~/.claude/hooks/`.
- Sandbox config is read at Claude session launch time — changes require restarting Claude Code.
- `gh auth token` returns short-lived OAuth tokens (`gho_*`). The `GITHUB_PERSONAL_ACCESS_TOKEN` env var is set dynamically in `.profile` so it refreshes each shell session.
