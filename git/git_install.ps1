$DotfilesDir = Split-Path $PSScriptRoot
$GitconfigTarget = Join-Path $PSScriptRoot ".gitconfig-windows"
$GitconfigLink = Join-Path $HOME ".gitconfig"

# =========================
# 1. Git config
# =========================

if (Test-Path $GitconfigLink) { Remove-Item $GitconfigLink -Force }
cmd /c mklink "$GitconfigLink" "$GitconfigTarget"

# =========================
# 2. GitHub SSH setup
# =========================

$SshDir = Join-Path $HOME ".ssh"
$SshKey = Join-Path $SshDir "id_ed25519"

if (Test-Path $SshKey) {
    Write-Host "SSH key already exists at $SshKey -skipping generation" -ForegroundColor Yellow
} else {
    Write-Host "Generating SSH key..." -ForegroundColor Cyan
    if (-not (Test-Path $SshDir)) { New-Item -ItemType Directory -Path $SshDir | Out-Null }
    ssh-keygen -t ed25519 -C "alex.darch@btinternet.com" -f $SshKey

    # Ensure ssh-agent is running
    $sshAgent = Get-Service -Name ssh-agent -ErrorAction SilentlyContinue
    if ($sshAgent) {
        if ($sshAgent.StartType -eq 'Disabled') {
            Set-Service -Name ssh-agent -StartupType Manual
        }
        Start-Service ssh-agent -ErrorAction SilentlyContinue
    }

    ssh-add $SshKey

    # Copy public key to clipboard
    Get-Content "$SshKey.pub" | Set-Clipboard
    Write-Host ""
    Write-Host "Public key copied to clipboard." -ForegroundColor Green
    Write-Host "Add it to GitHub: https://github.com/settings/ssh/new" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Press Enter after adding the key to GitHub"
}

# Verify GitHub connection
Write-Host "Testing GitHub SSH connection..." -ForegroundColor Cyan
ssh -T git@github.com 2>&1 | Write-Host
