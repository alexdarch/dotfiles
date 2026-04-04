# Dotfiles

Cross-platform dotfiles for WSL2 (primary), Windows, and Linux. Manages config for git, IDE, shell, and Claude Code.

## Quick Start (Windows + WSL2)

### 1. Install WSL2

From PowerShell (admin not required):

```powershell
.\install.ps1
```

This installs WSL2 with Ubuntu. When prompted, create a username and password.
The script also configures passwordless `sudo`.

### 2. Clone dotfiles in WSL

```bash
wsl
mkdir -p ~/source && cd ~/source
git clone https://github.com/alexdarch/dotfiles.git
```

Use HTTPS for the initial clone -- SSH keys aren't set up yet.

### 3. Run the bootstrap

```bash
~/source/dotfiles/wsl_bootstrap.sh
```

This installs system packages (`bubblewrap`, `socat`, `git`, etc.), `uv`, Claude Code,
then runs the dotfiles installer which sets up git config, VS Code extensions, and Claude Code.

The bootstrap also generates SSH keys via `git_install.sh` and prompts you to add
them to GitHub. After that, it switches the dotfiles remote from HTTPS to SSH.

### 4. Open VS Code

From Windows Explorer, access WSL files at:

```
\\wsl$\Ubuntu\home\$env:USERNAME
```

Or from inside WSL:

```bash
code ~/source/<project>
```

Install the [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) in VS Code if prompted.

## What Gets Installed

| Component | What it does |
|-----------|-------------|
| `git/` | Symlinks `.gitconfig`, sets up GitHub SSH keys |
| `ide/` | Installs VS Code extensions from `vscode_extensions.txt` |
| `claude_setup/` | Claude Code settings, hooks, skills, statusline |

### Claude Code Setup

- `settings.yaml` is the source of truth -- converted to `generated-settings.json` at install time
- `hooks/` directory is symlinked to `~/.claude/hooks`
  - `event-logger.py` -- logs hook events for debugging
  - `encourage_skill_usage.py` -- suggests relevant skills on each prompt via Haiku
- `skills/build_skills_yaml.py` scans `~/.claude` for SKILL.md files and writes `~/.claude/skills.yaml` at install time
- Bubblewrap sandbox is active in WSL2, providing OS-level isolation for Bash subprocesses

## Re-running

After making changes to dotfiles, re-run the relevant installer:

```bash
# Everything
~/source/dotfiles/install.sh

# Just Claude Code config
~/source/dotfiles/claude_setup/install_claude.sh
```

## Structure

```
wsl_bootstrap.sh          # WSL2 first-time setup: packages, uv, claude, then runs install.sh
install.ps1               # Windows: installs WSL2 + configures passwordless sudo
install.sh                # Linux/WSL2: runs all sub-installers

git/
  .gitconfig              # Global git config (symlinked to ~/.gitconfig)
  git_install.sh          # Symlinks .gitconfig + GitHub SSH setup

ide/
  vscode_extensions.txt   # Extension list, supports pinned versions (ext@1.0.0)
  install_ide.sh          # Installs VS Code extensions

shell/
  profile.ps1             # PowerShell profile (Windows-only, kept for reference)

claude_setup/
  settings.yaml           # Source of truth for Claude Code settings
  generated-settings.json # Auto-generated from yaml -- do NOT edit directly
  CLAUDE.md               # Global Claude Code instructions (symlinked to ~/.claude/)
  install_claude.sh       # Converts yaml, symlinks, runs shared config
  configure_claude.sh     # Shared claude CLI commands (plugins, MCPs)
  statusline/
    statusline.sh         # Statusline script for Claude Code
  hooks/                  # Symlinked as directory to ~/.claude/hooks
    event-logger.py       # Logs hook events to ~/.claude/hooks-logs/
    encourage_skill_usage.py  # Suggests relevant skills via Haiku
  skills/
    build_skills_yaml.py      # Scans ~/.claude for SKILL.md files -> ~/.claude/skills.yaml
    test_build_skills_yaml.py # Tests for build_skills_yaml.py
```
