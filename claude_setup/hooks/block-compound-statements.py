#!/usr/bin/env -S uv run --script
"""Hook: block compound Bash commands and tell Claude how to retry.

Use the PreToolUse hoook SpecificOutput protocol (exit 0 + JSON on stdout) so
the deny reason is surfaced to Claude as a retry hint, not a generic error.

Two cases:
    1. `cd <path> (&&|;|||) <rest>` -> strip the cd prefix and suggest running <rest> directly.
        Claude retries in one call instead of 3 (pwd/cd/run)
    2. Any other compound (contains &&, ;, ||) -> ask Claude to send each command as a seperate
        bash call.
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
    if not _COMPOUND.search(command):
        return 0
    
    stripped = _CD_PREFIX.sub("", command).strip()
    if stripped and stripped != command:
        reason = (
            f"Do not prefix commands with 'cd'. Run this directly: {stripped}"
        )
    else:
        reason = (
            "Compound commands are not allowed (contains &&, ;, or ||). "
            "Run each command as a separate Base tool call."
        )

    _debug_log(f"DENY: {reason}")

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": reason
        }
    }))
    return


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
