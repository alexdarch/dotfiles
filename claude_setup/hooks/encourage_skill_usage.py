#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "anthropic",
#     "pyyaml",
# ]
# ///
"""
UserPromptSubmit hook: suggests relevant skills based on the user's prompt.
Reads ~/.claude/skills.yaml (built by build_skills_yaml.py at install time),
asks Haiku to match, and injects context if any skills apply.
"""

import json
import sys
from pathlib import Path

import yaml
from anthropic import Anthropic

SKILLS_YAML = Path.home() / ".claude" / "skills.yaml"


def load_skills() -> list[dict[str, str]]:
    if not SKILLS_YAML.exists():
        return []
    data = yaml.safe_load(SKILLS_YAML.read_text(encoding="utf-8"))
    return data.get("skills", []) if data else []


def match_skills(user_prompt: str, skills: list[dict[str, str]]) -> list[str]:
    if not skills:
        return []

    skills_text = "\n".join(
        f"- {s['name']}: {s['description']}" for s in skills
    )

    client = Anthropic()
    response = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=256,
        messages=[
            {
                "role": "user",
                "content": f"""Return ONLY a JSON array of skill names that are relevant to this request. Return [] if none match.

Request: {user_prompt}

Skills:
{skills_text}

Format: ["skill-name"] or []""",
            }
        ],
    )

    text = response.content[0].text.strip()
    try:
        result = json.loads(text)
        if isinstance(result, list):
            return [s for s in result if isinstance(s, str)]
    except json.JSONDecodeError:
        pass
    return []


def main() -> None:
    stdin_data = sys.stdin.read()
    try:
        data = json.loads(stdin_data) if stdin_data else {}
    except json.JSONDecodeError:
        return

    user_prompt = data.get("prompt", "")
    if not user_prompt:
        return

    skills = load_skills()
    if not skills:
        return

    matched = match_skills(user_prompt, skills)
    if not matched:
        return

    skills_list = ", ".join(matched)
    output = {
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": (
                f"Potentially useful skills: {skills_list}\n"
                "If you have not already invoked these skills and they seem relevant, "
                "you MUST invoke them immediately using the Skill tool."
            ),
        }
    }
    print(json.dumps(output))


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"[encourage-skill-usage] Error: {e}", file=sys.stderr)
