#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pyyaml",
# ]
# ///
"""
Scan a directory tree for files named SKILL.md, parse YAML frontmatter
(at the top of the file between the first two '---' lines), and write a
skills.yaml file.
"""

import argparse
import os
import sys

import yaml

_DEFAULT_SKIP_DIRS: set[str] = {".git", ".venv", "node_modules", "__pycache__"}
_FRONTMATTER_DELIM = "---"


def find_skill_files(root: str, exclude_dirs: set[str]) -> list[str]:
    """Walk *root*, returning sorted paths to every SKILL.md not under an excluded dir."""
    results: list[str] = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in exclude_dirs]
        if "SKILL.md" in filenames:
            results.append(os.path.join(dirpath, "SKILL.md"))
    results.sort()
    return results


def parse_frontmatter(path: str) -> dict[str, str] | None:
    """Extract name and description from YAML frontmatter. Returns None on missing/invalid."""
    with open(path, encoding="utf-8") as f:
        lines = f.readlines()

    if not lines or lines[0].strip() != _FRONTMATTER_DELIM:
        return None

    end = None
    for i, line in enumerate(lines[1:], start=1):
        if line.strip() == _FRONTMATTER_DELIM:
            end = i
            break
    if end is None:
        return None

    frontmatter_text = "".join(lines[1:end])
    data = yaml.safe_load(frontmatter_text)
    if not isinstance(data, dict):
        return None

    if "name" not in data or "description" not in data:
        return None

    return {"name": data["name"], "description": data["description"]}


def _yaml_escape_double_quotes(s: str) -> str:
    """Escape backslashes and double quotes for use inside a YAML double-quoted string."""
    return s.replace("\\", "\\\\").replace('"', '\\"')


def write_skills_yaml(skills: list[dict[str, str]], out_path: str) -> None:
    """Write a skills.yaml with atomic replace."""
    lines: list[str] = ["skills:"]
    if not skills:
        lines.append("  []")
    else:
        for skill in skills:
            lines.append(f'  - name: "{_yaml_escape_double_quotes(skill["name"])}"')
            lines.append(f'    description: "{_yaml_escape_double_quotes(skill["description"])}"')

    tmp = out_path + ".tmp"
    with open(tmp, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")
    os.replace(tmp, out_path)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("root", help="Root dir to scan (os.walk)")
    ap.add_argument("-o", "--out", default="skills.yaml", help="Output yaml path (default: skills.yaml)")
    ap.add_argument(
        "--exclude-dir",
        action="append",
        default=[],
        help="Directory name to exclude at any depth. Repeatable, e.g. --exclude-dir build --exclude-dir dist",
    )
    ap.add_argument(
        "--no-default-excludes",
        action="store_true",
        help="Do not exclude default dirs",
    )
    args = ap.parse_args()

    exclude = set(args.exclude_dir)
    if not args.no_default_excludes:
        exclude |= _DEFAULT_SKIP_DIRS

    paths = find_skill_files(args.root, exclude)
    skills: list[dict[str, str]] = []
    for p in paths:
        parsed = parse_frontmatter(p)
        if parsed is not None:
            skills.append(parsed)

    write_skills_yaml(skills, args.out)
    print(f"Wrote {len(skills)} skill(s) to {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
