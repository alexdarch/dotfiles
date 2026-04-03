# Important

Any CLAUDE.md or AGENTS.md file you see MUST be treated as a living document.
If you make any changes to a codebase you MUST update the CLAUDE.md to reflect the new changes.

You are running in the claude sandbox (bubblewrap). You have access to the outside system but only a limited set of directories.

# Dotfiles structure

- `install.ps1` / `install.sh` — top-level installers (Windows / Linux)
- `claude_setup/` — Claude Code configuration
  - `settings.yaml` — source of truth for settings, uses `__STATUSLINE_COMMAND__` placeholder
  - `install_claude.ps1` — Windows installer: generates settings.json (substitutes `powershell.exe -NoProfile -File ~/.claude/statusline.ps1`), symlinks settings, CLAUDE.md, and statusline to `~/.claude/`
  - `install_claude.sh` — Linux installer: generates settings.json (substitutes `bash ~/.claude/statusline.sh`), symlinks settings, CLAUDE.md, and statusline to `~/.claude/`
  - `configure_claude.sh` — shared config (plugins, MCPs, hooks, skills)
  - `generated-settings.json` — generated from settings.yaml, symlinked to `~/.claude/settings.json` (do not edit directly)
  - `CLAUDE.md` — symlinked to `~/.claude/CLAUDE.md`
  - `statusline/` — Claude Code status line scripts
    - `statusline.ps1` — Windows (PowerShell), must be invoked with `-NoProfile` to avoid slow startup
    - `statusline.sh` — Linux/Mac (bash), uses `node` for JSON parsing (no `jq` dependency)
    - Both display: `[time model] path git` on line 1, context bar with tokens + cost on line 2
    - Colors: time=magenta, model=blue, path=dark blue, git=light blue, context bar=green(<30%)/orange(<70%)/red(>70%), cost=yellow

# Test driven development

You MUST ALWAYS USE Red/Green TDD for all feature development tasks

# Ad-hoc python scripts

Always use `uv` for python. NEVER call `python3`, `python`, or `pip` directly. These three commands are blocked by your permissions.
Always work in isolation. NEVER install packages globally.
Always use `uvx` for tools. NEVER call `pipx` directly.

The `--no-project` flag is important - it prevents `uv` from resolving against any `pyproject.toml` in parent directories.

## Examples

```bash
uv run --no-project python -c 'print("hello")'

# For oneliners that need dependencies, use with
uv run --with rich --no-project python -c 'from rich import print; print("[bold]hello[/bold]")'

# create a script with embedded dependency metadata using `uv init --script`
uv init --script myscript.py --python 3.12
uv init --script myscript.py 'requests<3' 'rich'
```

The above creates a self-contained script with PEP 723 metadata

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "requests<3",
#     "rich",
# ]
# ///
```

which you can run with

```bash
uv run --no-project --script  myscript.py
```