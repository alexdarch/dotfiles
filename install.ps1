# =========================
# Install WSL2 (Ubuntu)
# =========================

Write-Host "Checking WSL status..." -ForegroundColor Cyan

$wslList = wsl --list --quiet 2>&1
if ($LASTEXITCODE -ne 0 -or -not ($wslList -match "Ubuntu")) {
    Write-Host "Installing WSL2 with Ubuntu..." -ForegroundColor Cyan
    wsl --install -d Ubuntu

    # After install completes, Ubuntu will launch and prompt for username/password.
    # Set those, then continue below or re-run this script.
} else {
    Write-Host "WSL2 Ubuntu is already installed." -ForegroundColor Green
}

# Make the WSL user passwordless for sudo
Write-Host "Configuring passwordless sudo..." -ForegroundColor Cyan
$wslUser = wsl whoami
$wslUser = $wslUser.Trim()
wsl -u root bash -c "echo '$wslUser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$wslUser && chmod 440 /etc/sudoers.d/$wslUser"

Write-Host ""
Write-Host "WSL2 is ready." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Enter WSL:        wsl"
Write-Host "  2. Clone dotfiles:   git clone https://github.com/alexdarch/dotfiles.git ~/source/dotfiles"
Write-Host "  3. Run bootstrap:    ~/source/dotfiles/wsl_bootstrap.sh"
Write-Host ""
Write-Host "Access WSL files from Windows Explorer at: \\wsl$\Ubuntu\home\$wslUser" -ForegroundColor Cyan
Write-Host "Or open VS Code into WSL:                  code --remote wsl+Ubuntu /home/$wslUser" -ForegroundColor Cyan

# =========================
# Previous Windows-native setup (kept for reference)
# =========================

# # Check Developer Mode is enabled (required for symlinks without admin)
# $devModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
# $devMode = (Get-ItemProperty -Path $devModePath -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
# if ($devMode -ne 1) {
#     Write-Host "Developer Mode is not enabled. Please enable it:" -ForegroundColor Red
#     Write-Host "  1. Open Settings (Win+I)"
#     Write-Host "  2. Go to System > For developers"
#     Write-Host "  3. Toggle 'Developer Mode' on"
#     Write-Host "  4. Re-run this script"
#     exit 1
# }
#
# $DotfilesDir = $PSScriptRoot
#
# # Symlink PowerShell profile
# $ProfileTarget = Join-Path $DotfilesDir "shell\profile.ps1"
# $ProfileLink = Join-Path $HOME "OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
# if (Test-Path $ProfileLink) { Remove-Item $ProfileLink -Force }
# cmd /c mklink "$ProfileLink" "$ProfileTarget"
#
# # Install git config
# & "$DotfilesDir\git\git_install.ps1"
#
# # Install IDE extensions
# & "$DotfilesDir\ide\install_ide.ps1"
#
# # Install Claude Code config
# & "$DotfilesDir\claude_setup\install_claude.ps1"
