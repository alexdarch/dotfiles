# =========================
# Dotfiles Installer (Windows)
# =========================

Write-Host ""
Write-Host "==========================" -ForegroundColor Cyan
Write-Host " Dotfiles Setup (Windows)" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Choose your setup:" -ForegroundColor White
Write-Host ""
Write-Host "  [1] WSL2 (Windows Subsystem for Linux)" -ForegroundColor Green
Write-Host "      Best for: websites, games, Python apps, dev tools, Claude Code"
Write-Host "      Runs a full Linux environment inside Windows."
Write-Host ""
Write-Host "  [2] Native Windows" -ForegroundColor Yellow
Write-Host "      Best for: Microsoft Office integrations only"
Write-Host "      Has major limitations with sandboxing and safety."
Write-Host ""

$choice = Read-Host "Enter 1 or 2"

switch ($choice) {
    "1" {
        # =========================
        # WSL2 Setup
        # =========================

        Write-Host ""
        Write-Host "Setting up WSL2..." -ForegroundColor Cyan

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
        Write-Host "  3. Run bootstrap:    ~/source/dotfiles/install.sh"
        Write-Host ""
        Write-Host "Access WSL files from Windows Explorer at: \\wsl$\Ubuntu\home\$wslUser" -ForegroundColor Cyan
        Write-Host "Or open VS Code into WSL:                  code --remote wsl+Ubuntu /home/$wslUser" -ForegroundColor Cyan
    }

    "2" {
        # =========================
        # Native Windows Setup
        # =========================

        Write-Host ""
        Write-Host "Setting up native Windows..." -ForegroundColor Yellow
        Write-Host "Note: Claude Code sandbox is not supported on native Windows." -ForegroundColor Yellow
        Write-Host ""

        # Check Developer Mode (required for symlinks without admin)
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

        # Install packages via winget
        Write-Host "Installing packages..." -ForegroundColor Cyan
        $WingetPackages = @(
            "GitHub.cli"
            "Git.Git"
        )
        foreach ($pkg in $WingetPackages) {
            $null = winget list --id $pkg --exact --accept-source-agreements 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  $pkg already installed" -ForegroundColor Green
            } else {
                Write-Host "  Installing $pkg..." -ForegroundColor Cyan
                winget install --id $pkg --accept-package-agreements --accept-source-agreements
            }
        }

        # Symlink PowerShell profile
        Write-Host "Symlinking PowerShell profile..." -ForegroundColor Cyan
        $ProfileTarget = Join-Path $DotfilesDir "shell\profile.ps1"
        $ProfileDir = Join-Path $HOME "Documents\WindowsPowerShell"
        if (-not (Test-Path $ProfileDir)) { New-Item -ItemType Directory -Path $ProfileDir | Out-Null }
        $ProfileLink = Join-Path $ProfileDir "Microsoft.PowerShell_profile.ps1"
        if (Test-Path $ProfileLink) { Remove-Item $ProfileLink -Force }
        cmd /c mklink "$ProfileLink" "$ProfileTarget"

        # Git config
        Write-Host "Setting up git..." -ForegroundColor Cyan
        & "$DotfilesDir\git\git_install.ps1"

        # IDE extensions
        Write-Host "Setting up IDE..." -ForegroundColor Cyan
        & "$DotfilesDir\ide\install_ide.ps1"

        # Claude Code config
        Write-Host "Setting up Claude Code..." -ForegroundColor Cyan
        & "$DotfilesDir\claude_setup\install_claude.ps1"

        Write-Host ""
        Write-Host "==========================" -ForegroundColor Green
        Write-Host " Setup complete!" -ForegroundColor Green
        Write-Host "==========================" -ForegroundColor Green
    }

    default {
        Write-Host "Invalid choice. Please re-run and enter 1 or 2." -ForegroundColor Red
        exit 1
    }
}
