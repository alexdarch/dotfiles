$ErrorActionPreference = "Stop"

$ScriptDir = $PSScriptRoot
$DotfilesDir = Split-Path $ScriptDir

# =======================
# 1. Install Claude Code
# =======================

if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Claude Code..." -ForegroundColor Cyan
    irm https://claude.ai/install.ps1 | iex
}

# =======================
# 2. Settings and symlinks
# =======================

Write-Host "Installing claude CLI config..." -ForegroundColor Cyan
$ClaudeDir = Join-Path $HOME ".claude"
if (-not (Test-Path $ClaudeDir)) { New-Item -ItemType Directory -Path $ClaudeDir | Out-Null }

# Generate settings.json from yaml using uv + pyyaml (powershell-yaml mangles nested structures)
$GeneratedSettings = Join-Path $ScriptDir "generated-settings.json"
$SettingsYaml = Join-Path $ScriptDir "settings.yaml"
& uv run --with pyyaml --no-project python -c "
import yaml, json, sys
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
j = json.dumps(data, indent=2)
j = j.replace('__STATUSLINE_COMMAND__', 'powershell.exe -NoProfile -File ~/.claude/statusline.ps1')
j = j.replace('__TEMP_DIR__', '//tmp')
j = j.replace('__APPDATA_DIR__', '~/AppData/Local')
with open(sys.argv[2], 'w', encoding='utf-8', newline='\n') as f:
    f.write(j + '\n')
" $SettingsYaml $GeneratedSettings

# Build skills.yaml from all SKILL.md files under ~/.claude
Write-Host "Building skills.yaml..." -ForegroundColor Cyan
$SkillsScript = Join-Path $ScriptDir "skills\build_skills_yaml.py"
$SkillsOut = Join-Path $ClaudeDir "skills.yaml"
& uv run --no-project --script $SkillsScript $ClaudeDir -o $SkillsOut

# Symlink settings, CLAUDE.md, and hooks dir
$Symlinks = @{
    (Join-Path $ClaudeDir "settings.json")  = Join-Path $ScriptDir "generated-settings.json"
    (Join-Path $ClaudeDir "CLAUDE.md")      = Join-Path $ScriptDir "CLAUDE.md"
    (Join-Path $ClaudeDir "statusline.ps1") = Join-Path $ScriptDir "statusline\statusline.ps1"
    (Join-Path $ClaudeDir "hooks")          = Join-Path $ScriptDir "hooks"
}

foreach ($link in $Symlinks.GetEnumerator()) {
    if (Test-Path $link.Key) { Remove-Item $link.Key -Force -Recurse }
    if (Test-Path $link.Value) {
        $isDir = (Get-Item $link.Value).PSIsContainer
        if ($isDir) {
            cmd /c mklink /D "$($link.Key)" "$($link.Value)"
        } else {
            cmd /c mklink "$($link.Key)" "$($link.Value)"
        }
    } else {
        Write-Host "WARNING: $($link.Value) not found, skipping symlink" -ForegroundColor Yellow
    }
}

# =======================
# 3. Shared claude CLI config (plugins, MCPs, hooks, skills)
# =======================

# =======================
# 3. Windows-only plugins
# =======================

Write-Host "Installing Windows-only plugins..." -ForegroundColor Cyan

# Document handling (docx, pdf, pptx, xlsx) — useful for Office integrations on Windows
claude plugin marketplace add https://github.com/anthropics/skills.git
claude plugin install document-skills@anthropic-agent-skills

# =======================
# 4. Shared claude CLI config (plugins, MCPs, hooks, skills)
# =======================

Write-Host "Running shared claude configuration..." -ForegroundColor Cyan
bash "$ScriptDir\configure_claude.sh"

Write-Host "CLAUDE SETUP COMPLETE" -ForegroundColor Green
