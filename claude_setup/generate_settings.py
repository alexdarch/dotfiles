#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pyyaml",
# ]
# ///
"""Generate settings.json from settings.yaml with platform-specific replacements."""

import argparse
import json
import re
import sys
from pathlib import Path

import yaml

PLATFORM_CONFIG = {
    "linux": {
        "statusline_command": "bash ~/.claude/statusline.sh",
        "temp_dir": "/tmp",
        "remove_env_keys": ["CLAUDE_CODE_USE_POWERSHELL_TOOL"],
        "remove_appdata_lines": True,
    },
    "windows": {
        "statusline_command": "powershell.exe -NoProfile -File ~/.claude/statusline.ps1",
        "temp_dir": "//tmp",
        "appdata_dir": "~/AppData/Local",
        "remove_env_keys": [],
        "remove_appdata_lines": False,
    },
}


def generate(yaml_path: Path, output_path: Path, platform: str) -> None:
    config = PLATFORM_CONFIG[platform]

    with open(yaml_path) as f:
        data = yaml.safe_load(f)

    for key in config["remove_env_keys"]:
        data.get("env", {}).pop(key, None)

    j = json.dumps(data, indent=2)

    j = j.replace("__STATUSLINE_COMMAND__", config["statusline_command"])
    j = j.replace("__TEMP_DIR__", config["temp_dir"])

    if config["remove_appdata_lines"]:
        j = "\n".join(l for l in j.splitlines() if "__APPDATA_DIR__" not in l)
        j = re.sub(r",(\s*[\]\}])", r"\1", j)
    else:
        j = j.replace("__APPDATA_DIR__", config["appdata_dir"])

    with open(output_path, "w", encoding="utf-8", newline="\n") as f:
        f.write(j + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate settings.json from settings.yaml")
    parser.add_argument("platform", choices=["linux", "windows"])
    parser.add_argument("--input", default=None, help="Path to settings.yaml")
    parser.add_argument("--output", default=None, help="Path to generated-settings.json")
    args = parser.parse_args()

    script_dir = Path(__file__).resolve().parent
    yaml_path = Path(args.input) if args.input else script_dir / "settings.yaml"
    output_path = Path(args.output) if args.output else script_dir / "generated-settings.json"

    if not yaml_path.exists():
        print(f"ERROR: {yaml_path} not found", file=sys.stderr)
        sys.exit(1)

    generate(yaml_path, output_path, args.platform)
    print(f"Generated {output_path} for {args.platform}")


if __name__ == "__main__":
    main()
