# Dotfiles

Cross-platform dotfiles for WSL2 (primary), Windows, and Linux. Manages config for git, IDE, shell, and Claude Code.
If you are making changes to this repo then it is this CLAUDE.md (./CLAUDE.md) you should change.
The ./claude_setup/CLAUDE.md is the global one symlinked to ~/.claude/CLAUDE.md. DO NOT CHANGE THIS UNLESS SPECIFICALLY ASKED.

## Structure

```
wsl_bootstrap.sh     # WSL2 first-time setup: packages, uv, claude, then runs install.sh
install.ps1          # Windows entry point - installs WSL2 (previous native setup commented out)
install.sh           # Linux/WSL2 entry point - runs all sub-installers

git/
  .gitconfig         # Global git config (symlinked to ~/.gitconfig)
  git_install.ps1    # Windows: symlinks .gitconfig + GitHub SSH setup
  git_install.sh     # Linux: same

ide/
  vscode_extensions.txt   # Extension list, supports pinned versions (e.g. ext@1.0.0)
  install_ide.ps1         # Windows: installs VS Code extensions
  install_ide.sh          # Linux: same

shell/
  profile.ps1        # PowerShell profile (symlinked to WindowsPowerShell dir)

claude_setup/
  settings.yaml           # Source of truth for Claude Code settings (has comments)
  generated-settings.json # Auto-generated from yaml - do NOT edit directly
  CLAUDE.md               # Global Claude Code instructions (symlinked to ~/.claude/)
  install_claude.ps1      # Windows: converts yaml, symlinks, runs shared config
  install_claude.sh       # Linux: same
  configure_claude.sh     # Shared claude CLI commands (plugins, MCPs, hooks, skills)
  statusline/
    statusline.ps1        # Windows statusline script
    statusline.sh         # Linux statusline script
  hooks/                  # Symlinked as directory to ~/.claude/hooks
    event-logger.py       # Logs hook events to ~/.claude/hooks-logs/
    encourage_skill_usage.py  # UserPromptSubmit hook: suggests relevant skills via Haiku
  skills/
    build_skills_yaml.py  # Scans ~/.claude for SKILL.md files, writes ~/.claude/skills.yaml
    test_build_skills_yaml.py  # Tests for build_skills_yaml.py
```

## Conventions

- Primary dev environment is WSL2; `install.ps1` just bootstraps WSL
- `wsl_bootstrap.sh` handles first-time WSL2 setup (packages, uv, claude), then calls `install.sh`
- Each subdirectory has its own install script in both `.ps1` (Windows) and `.sh` (Linux) variants
- `settings.yaml` uses `__STATUSLINE_COMMAND__` as a placeholder, replaced at install time per platform
- `generated-settings.json` is gitignored output - always regenerate from `settings.yaml`
- Shared cross-platform logic (claude CLI commands) goes in `.sh` files called via `bash` from both platforms
