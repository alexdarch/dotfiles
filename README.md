# Dotfiles

Cross-platform dotfiles for WSL2 (primary), Windows, and Linux. Manages config for shell, git, IDE, and Claude Code.

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

### 3. Run the installer

```bash
cd ~/source/dotfiles
chmod +x install.sh packages/install_packages.sh shell/install_shell.sh
./install.sh
```

This installs everything in order:
1. **Packages** -- system packages (apt), uv, Claude Code, starship, zoxide, eza, ripgrep, fzf
2. **Shell** -- symlinks `.profile`, `.bashrc`, `.zshrc`, sets zsh as default
3. **Git** -- symlinks `.gitconfig-linux`, generates SSH keys, prompts to add to GitHub
4. **IDE** -- symlinks VS Code settings, installs extensions
5. **Claude Code** -- generates `settings.json` from yaml, symlinks hooks/statusline/CLAUDE.md
6. **Git remote** -- switches dotfiles remote from HTTPS to SSH

### 4. Open VS Code

From inside WSL:

```bash
code ~/source/<project>
```

Install the [WSL extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl) in VS Code if prompted.

## Shell Setup

Default shell is **zsh** with:
- **zinit** -- lightweight plugin manager (auto-installs on first launch)
- **fast-syntax-highlighting** -- command syntax coloring
- **zsh-autosuggestions** -- fish-like history suggestions
- **zsh-completions** -- extra tab completions
- **fzf** -- fuzzy finder for history (`Ctrl+R`), files (`Ctrl+T`), directories (`Alt+C`)
- **zoxide** -- smarter `cd` that learns your frequent directories (`z <partial-name>`)
- **eza** -- modern `ls` replacement with git integration
- **ripgrep** -- fast `grep` replacement

Prompt format: `user@host: path [git-branch status] $`

Bash is also configured as a fallback with the same prompt style and shared aliases.

## Claude Code Setup

- `settings.yaml` is the source of truth -- converted to `generated-settings.json` at install time
- Platform placeholders (`__STATUSLINE_COMMAND__`, `__TEMP_DIR__`, `__APPDATA_DIR__`) are replaced per platform
- `hooks/` directory is symlinked to `~/.claude/hooks`
  - `event-logger.py` -- logs hook events for debugging
  - `encourage_skill_usage.py` -- suggests relevant skills on each prompt via Haiku
- `skills/build_skills_yaml.py` scans `~/.claude` for SKILL.md files and writes `~/.claude/skills.yaml`
- Bubblewrap sandbox is active in WSL2, providing OS-level isolation for Bash subprocesses

## Re-running

After making changes to dotfiles, re-run the relevant installer:

```bash
# Everything
~/source/dotfiles/install.sh

# Just Claude Code config
~/source/dotfiles/claude_setup/install_claude.sh

# Just shell config
~/source/dotfiles/shell/install_shell.sh
```

## Structure

```
install.sh           # Single entry point — packages, shell, git, IDE, claude, remote switch
install.ps1          # Windows: installs WSL2 + configures passwordless sudo

packages/
  install_packages.sh # System packages (apt), uv, Claude Code, starship, zoxide

git/
  .gitconfig-linux   # Linux/WSL git config (symlinked to ~/.gitconfig)
  .gitconfig-windows # Windows git config (symlinked to ~/.gitconfig)
  git_install.sh     # Symlinks .gitconfig-linux + GitHub SSH setup
  git_install.ps1    # Windows variant

ide/
  vscode_settings.json    # VS Code user settings (symlinked to Code/User/settings.json)
  vscode_extensions.txt   # Extension list, supports pinned versions (ext@1.0.0)
  install_ide.sh          # Symlinks settings, installs extensions
  install_ide.ps1         # Windows variant

shell/
  .profile           # Shared env vars, PATH, aliases (sourced by .bashrc and .zshrc)
  .bashrc            # Bash-specific: history, completions, fzf
  .zshrc             # Zsh-specific: zinit, plugins, fzf
  prompt.bash        # Bash prompt: user@host: path [git] $ (uses __git_ps1)
  prompt.zsh         # Zsh prompt: user@host: path [git] $ (uses __git_ps1)
  install_shell.sh   # Symlinks shell configs, sets zsh as default
  profile.ps1        # PowerShell profile (Windows-only)

claude_setup/
  settings.yaml           # Source of truth for Claude Code settings
  generated-settings.json # Auto-generated from yaml — do NOT edit directly
  CLAUDE.md               # Global Claude Code instructions (symlinked to ~/.claude/)
  install_claude.sh       # Converts yaml, symlinks, runs shared config
  install_claude.ps1      # Windows variant
  configure_claude.sh     # Shared claude CLI commands (plugins, MCPs)
  statusline/
    statusline.sh         # Linux statusline script (uses uv/python for JSON parsing)
    statusline.ps1        # Windows statusline script
  hooks/                  # Symlinked as directory to ~/.claude/hooks
    event-logger.py       # Logs hook events to ~/.claude/hooks-logs/
    encourage_skill_usage.py  # Suggests relevant skills via Haiku
  skills/
    build_skills_yaml.py      # Scans ~/.claude for SKILL.md files -> ~/.claude/skills.yaml
    test_build_skills_yaml.py # Tests for build_skills_yaml.py
```
