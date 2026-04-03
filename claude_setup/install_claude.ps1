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

# Generate settings.json from yaml using powershell-yaml module
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Host "Installing powershell-yaml module..." -ForegroundColor Cyan
    Install-Module -Name powershell-yaml -Force -Repository PSGallery -Scope CurrentUser
}
$GeneratedSettings = Join-Path $ScriptDir "generated-settings.json"
$RawYaml = Get-Content -Raw (Join-Path $ScriptDir "settings.yaml")
$PsObj = ConvertFrom-Yaml -Yaml $RawYaml
$Json = $PsObj | ConvertTo-Json -Depth 20
$Json = $Json -replace "__STATUSLINE_COMMAND__", "powershell.exe -NoProfile -File ~/.claude/statusline.ps1"
$Json | Out-File -Encoding utf8 $GeneratedSettings

# Symlink settings and CLAUDE.md
$Symlinks = @{
    (Join-Path $ClaudeDir "settings.json")  = Join-Path $ScriptDir "generated-settings.json"
    (Join-Path $ClaudeDir "CLAUDE.md")      = Join-Path $ScriptDir "CLAUDE.md"
    (Join-Path $ClaudeDir "statusline.ps1") = Join-Path $ScriptDir "statusline\statusline.ps1"
}

foreach ($link in $Symlinks.GetEnumerator()) {
    if (Test-Path $link.Key) { Remove-Item $link.Key -Force }
    if (Test-Path $link.Value) {
        cmd /c mklink "$($link.Key)" "$($link.Value)"
    } else {
        Write-Host "WARNING: $($link.Value) not found, skipping symlink" -ForegroundColor Yellow
    }
}

# =======================
# 3. Shared claude CLI config (plugins, MCPs, hooks, skills)
# =======================

Write-Host "Running shared claude configuration..." -ForegroundColor Cyan
bash "$ScriptDir\configure_claude.sh"

Write-Host "CLAUDE SETUP COMPLETE" -ForegroundColor Green
