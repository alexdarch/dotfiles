#!/usr/bin/env -S uv run --script


import sys
import json
import os
from datetime import datetime
from pathlib import Path
from typing import Any

def get_log_file_path() -> Path:
    log_dir = Path.home() / ".claude" / "hooks-logs"
    log_dir.mkdir(parents=True, exist_ok=True)
    return log_dir / f"{datetime.now().strftime('%Y-%m-%d')}.jsonl"

def truncate(value: str, max_len: int=2000) -> str:
    if isinstance(value, str) and len(value) > max_len:
        return f"{value[:max_len]}... ({len(value)} chars)"
    return value

def process(value: Any, max_str: int=2000, max_list: int=50) -> str:
    if value is None or isinstance(value, bool):
        return value
    if isinstance(value, str):
        return truncate(value, max_str)
    if isinstance(value, (int, float)):
        return value
    if isinstance(value, list):
        items = [process(v) for v in value[:max_list]]
        if len(value) > max_list:
            items.append(f"... +{len(value) - max_list} more")
        return items
    if isinstance(value, dict):
        return {str(k): process(v) for k, v in value.items()}
    return str(value)

def main() -> None:

    stdin_data = sys.stdin.read()

    try: 
        data = json.loads(stdin_data) if stdin_data else {}
    except json.JSONDecodeError:
        data = {"_raw": stdin_data }

    event = {
        "ts": datetime.now().isoformat(),
        "hook_event_name": data.get("hook_event_name", "unknown"),
        "cwd": os.getcwd(),
        "data": process(data),
    }

    log_file = get_log_file_path()
    with open(log_file, "a") as f:
        f.write(json.dumps(event, default=str) + "\n")


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"[event-logger] Error: {e}", file=sys.stderr)