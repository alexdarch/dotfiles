# Check Developer Mode is enabled (required for symlinks without admin)
$devModePath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
$devMode = (Get-ItemProperty -Path $devModePath -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense
if ($devMode -ne 1) {
    Write-Host "Developer Mode is not enabled. Please enable it:" -ForegroundColor Red
    Write-Host "  1. Open Settings (Win+I)"
    Write-Host "  2. Go to System > For developers"
    Write-Host "  3. Toggle 'Developer Mode' on"
    Write-Host "  4. Re-run this script"
    exit 1
}

$DotfilesDir = $PSScriptRoot

# Symlink PowerShell profile
$ProfileTarget = Join-Path $DotfilesDir "shell\profile.ps1"
$ProfileLink = Join-Path $HOME "OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $ProfileLink) { Remove-Item $ProfileLink -Force }
cmd /c mklink "$ProfileLink" "$ProfileTarget"

# Install git config
& "$DotfilesDir\git\git_install.ps1"

# Install IDE extensions
& "$DotfilesDir\ide\install_ide.ps1"

# Install Claude Code config
& "$DotfilesDir\claude_setup\install_claude.ps1"
