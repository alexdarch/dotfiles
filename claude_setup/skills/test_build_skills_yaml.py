#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pyyaml",
#     "pytest",
# ]
# ///
"""Tests for build_skills_yaml.py — run with: uv run --no-project --script test_build_skills_yaml.py"""

import importlib.util
import os
import tempfile
import textwrap
from pathlib import Path

import pytest

# Import the script as a module
_spec = importlib.util.spec_from_file_location(
    "build_skills_yaml",
    Path(__file__).parent / "build_skills_yaml.py",
)
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)

find_skill_files = _mod.find_skill_files
parse_frontmatter = _mod.parse_frontmatter
write_skills_yaml = _mod.write_skills_yaml
_yaml_escape_double_quotes = _mod._yaml_escape_double_quotes


# ── find_skill_files ──────────────────────────────────────────────


def _make_tree(base: Path, paths: list[str]) -> None:
    """Create empty files at the given relative paths."""
    for p in paths:
        full = base / p
        full.parent.mkdir(parents=True, exist_ok=True)
        full.write_text("")


class TestFindSkillFiles:
    def test_finds_skill_md_in_subdirs(self, tmp_path):
        _make_tree(tmp_path, [
            "a/SKILL.md",
            "b/c/SKILL.md",
        ])
        result = find_skill_files(str(tmp_path), set())
        assert len(result) == 2
        assert all(p.endswith("SKILL.md") for p in result)

    def test_returns_sorted_paths(self, tmp_path):
        _make_tree(tmp_path, [
            "z/SKILL.md",
            "a/SKILL.md",
        ])
        result = find_skill_files(str(tmp_path), set())
        assert result == sorted(result)

    def test_excludes_directories(self, tmp_path):
        _make_tree(tmp_path, [
            "good/SKILL.md",
            ".git/SKILL.md",
            "node_modules/deep/SKILL.md",
        ])
        result = find_skill_files(str(tmp_path), {".git", "node_modules"})
        assert len(result) == 1
        assert "good" in result[0]

    def test_empty_tree_returns_empty(self, tmp_path):
        result = find_skill_files(str(tmp_path), set())
        assert result == []

    def test_ignores_non_skill_md(self, tmp_path):
        _make_tree(tmp_path, [
            "a/SKILL.md",
            "a/README.md",
            "a/skill.md",  # wrong case
        ])
        result = find_skill_files(str(tmp_path), set())
        assert len(result) == 1


# ── parse_frontmatter ─────────────────────────────────────────────


class TestParseFrontmatter:
    def test_parses_name_and_description(self, tmp_path):
        f = tmp_path / "SKILL.md"
        f.write_text(textwrap.dedent("""\
            ---
            name: my-skill
            description: Does something useful
            ---
            # Body here
        """))
        result = parse_frontmatter(str(f))
        assert result == {"name": "my-skill", "description": "Does something useful"}

    def test_returns_none_without_frontmatter(self, tmp_path):
        f = tmp_path / "SKILL.md"
        f.write_text("# Just a heading\nNo frontmatter here.\n")
        result = parse_frontmatter(str(f))
        assert result is None

    def test_returns_none_if_name_missing(self, tmp_path):
        f = tmp_path / "SKILL.md"
        f.write_text(textwrap.dedent("""\
            ---
            description: no name field
            ---
        """))
        result = parse_frontmatter(str(f))
        assert result is None

    def test_returns_none_if_description_missing(self, tmp_path):
        f = tmp_path / "SKILL.md"
        f.write_text(textwrap.dedent("""\
            ---
            name: orphan
            ---
        """))
        result = parse_frontmatter(str(f))
        assert result is None

    def test_handles_extra_fields(self, tmp_path):
        f = tmp_path / "SKILL.md"
        f.write_text(textwrap.dedent("""\
            ---
            name: my-skill
            description: Does things
            version: 1.0
            ---
        """))
        result = parse_frontmatter(str(f))
        assert result == {"name": "my-skill", "description": "Does things"}

    def test_handles_multiword_description(self, tmp_path):
        f = tmp_path / "SKILL.md"
        f.write_text(textwrap.dedent("""\
            ---
            name: complex-skill
            description: A longer description with many words and special chars like & and "quotes"
            ---
        """))
        result = parse_frontmatter(str(f))
        assert result["name"] == "complex-skill"
        assert "quotes" in result["description"]


# ── _yaml_escape_double_quotes ────────────────────────────────────


class TestYamlEscape:
    def test_escapes_backslash(self):
        assert _yaml_escape_double_quotes("a\\b") == "a\\\\b"

    def test_escapes_double_quotes(self):
        assert _yaml_escape_double_quotes('say "hi"') == 'say \\"hi\\"'

    def test_plain_string_unchanged(self):
        assert _yaml_escape_double_quotes("hello world") == "hello world"


# ── write_skills_yaml ─────────────────────────────────────────────


class TestWriteSkillsYaml:
    def test_writes_valid_yaml(self, tmp_path):
        import yaml

        out = tmp_path / "skills.yaml"
        skills = [
            {"name": "alpha", "description": "First skill"},
            {"name": "beta", "description": "Second skill"},
        ]
        write_skills_yaml(skills, str(out))
        data = yaml.safe_load(out.read_text())
        assert len(data["skills"]) == 2
        assert data["skills"][0]["name"] == "alpha"
        assert data["skills"][1]["description"] == "Second skill"

    def test_empty_skills_list(self, tmp_path):
        import yaml

        out = tmp_path / "skills.yaml"
        write_skills_yaml([], str(out))
        data = yaml.safe_load(out.read_text())
        assert data["skills"] == []

    def test_escapes_special_chars_in_description(self, tmp_path):
        out = tmp_path / "skills.yaml"
        skills = [{"name": "tricky", "description": 'Has "quotes" and \\backslash'}]
        write_skills_yaml(skills, str(out))
        import yaml

        data = yaml.safe_load(out.read_text())
        assert data["skills"][0]["description"] == 'Has "quotes" and \\backslash'

    def test_atomic_write(self, tmp_path):
        """Output file should exist after write (atomic replace)."""
        out = tmp_path / "skills.yaml"
        write_skills_yaml([{"name": "x", "description": "y"}], str(out))
        assert out.exists()


if __name__ == "__main__":
    raise SystemExit(pytest.main([__file__, "-v"]))
