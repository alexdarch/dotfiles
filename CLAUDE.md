# Dotfiles

Cross-platform dotfiles for Windows (primary) and Linux. Manages config for git, IDE, shell, and Claude Code.

## Structure

```
install.ps1          # Windows entry point - runs all sub-installers
install.sh           # Linux entry point - runs all sub-installers

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
```

## Conventions

- Each subdirectory has its own install script in both `.ps1` (Windows) and `.sh` (Linux) variants
- The root `install.ps1`/`install.sh` calls all sub-installers
- Windows symlinks use `cmd /c mklink` (not `New-Item -SymbolicLink`) because it works with Developer Mode without admin
- Developer Mode must be enabled on Windows for symlinks to work
- `settings.yaml` uses `__STATUSLINE_COMMAND__` as a placeholder, replaced at install time per platform
- `generated-settings.json` is gitignored output - always regenerate from `settings.yaml`
- Shared cross-platform logic (claude CLI commands) goes in `.sh` files called via `bash` from both platforms
