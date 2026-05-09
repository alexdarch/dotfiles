#!/usr/bin/env -S uv run --script
"""Hook: block known-problem Bash patterns and tell Claude how to retry.

Use the PreToolUse hook SpecificOutput protocol (exit 0 + JSON on stdout) so
the deny reason is surfaced to Claude as a retry hint, not a generic error.

Cases:
    1. `cd <path> (&&|;|||) <rest>` -> strip the cd prefix and suggest running <rest> directly.
        Claude retries in one call instead of 3 (pwd/cd/run).
    2. Any other compound (contains &&, ;, ||) -> ask Claude to send each command as a separate
        bash call.
    3. `$TMPDIR` / `${TMPDIR}` outside single quotes -> tell Claude to use the literal
        /tmp/claude-1000/ path. The harness can't statically resolve env-var paths against
        sandbox bounds and prompts the user.
    4. Heredoc body containing `{...}` with a quote inside -> tell Claude to use the Write
        tool. The harness's brace-quote obfuscation detector fires and prompts the user.
"""

import json
import re
import sys
from pathlib import Path

DEBUG = False
LOG_DIR = Path.home() / ".claude" / "hooks-logs"
LOG_FILE = LOG_DIR / "block-compound-statement.log"

# Matches: cd/pushd <path> <op> at the start of command.
# <path> may be "double-quoted", 'single-quoted' or a bare token
# (permits $VAR, ~/foo, /aps/paht, etc). <op> is &&, ;, or ||
_CD_PREFIX = re.compile(
    r'^\s*(?:cd|pushd)\s+'
    r'(?:"[^"]*"|\'[^\']*\'|[^\s&;|]+)'
    r'\s*(?:&&|;|\|\|)\s*'
)

_COMPOUND = re.compile(r'&&|;|\|\|')

# $TMPDIR or ${TMPDIR} (env-var reference)
_TMPDIR_REF = re.compile(r'\$\{?TMPDIR\b\}?')

# Single-quoted strings — stripped before searching for unquoted env-var refs.
_SINGLE_QUOTED = re.compile(r"'[^']*'")

# Heredoc start: <<MARKER, <<-MARKER, <<'MARKER', <<"MARKER" (group 2 = marker).
_HEREDOC_START = re.compile(r'<<-?\s*([\'"]?)([A-Za-z_]\w*)\1')

# A brace pair containing a double-quote — same shape that trips Claude Code's
# obfuscation detector inside heredoc bodies.
_BRACE_QUOTE = re.compile(r'\{[^}]*"[^}]*\}')


def main() -> int:
    try:
        raw = sys.stdin.read()
        data = json.loads(raw)
    except Exception:
        return 0

    command = (
        data.get("tool_input", {}).get("command")
        if isinstance(data, dict)
        else None
    )
    _debug_log(f"INPUT: {(raw or '')[:300]}")

    if not isinstance(command, str) or not command:
        return 0

    for check in (_check_compound, _check_tmpdir, _check_heredoc_brace_quote):
        reason = check(command)
        if reason is None:
            continue
        _debug_log(f"DENY: {reason}")
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        }))
        return 0
    return 0


def _check_compound(command: str) -> str | None:
    if not _COMPOUND.search(command):
        return None
    stripped = _CD_PREFIX.sub("", command).strip()
    if stripped and stripped != command:
        return f"Do not prefix commands with 'cd'. Run this directly: {stripped}"
    return (
        "Compound commands are not allowed (contains &&, ;, or ||). "
        "Run each command as a separate Bash tool call."
    )


def _check_tmpdir(command: str) -> str | None:
    bare = _SINGLE_QUOTED.sub("", command)
    if not _TMPDIR_REF.search(bare):
        return None
    return (
        "Do not reference $TMPDIR in Bash commands. The static path-checker can't resolve "
        "env-var paths against the sandbox bounds and will force a permission prompt. "
        "Use the literal path /tmp/claude-1000/ instead."
    )


def _check_heredoc_brace_quote(command: str) -> str | None:
    for match in _HEREDOC_START.finditer(command):
        marker = match.group(2)
        body_pat = re.compile(
            r'\n(.*?)\n[ \t]*' + re.escape(marker) + r'\b',
            re.DOTALL,
        )
        body_match = body_pat.search(command, match.end())
        if not body_match:
            continue
        if _BRACE_QUOTE.search(body_match.group(1)):
            return (
                "Heredoc body contains a brace with a quote (e.g., `{ x = \"y\" }`), which "
                "triggers Claude Code's obfuscation detector and forces a permission prompt. "
                "Use the Write tool to create the file instead."
            )
    return None


def _debug_log(content: str) -> None:
    if not DEBUG:
        return
    
    try:
        LOG_DIR.mkdir(parents=True, exist_okay=True)
        with LOG_FILE.open("a") as f:
            f.write(content + "\n")
    except Exception:
        pass


if __name__ == "__main__":
    sys.exit(main())
