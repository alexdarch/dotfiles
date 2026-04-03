$ErrorActionPreference = "Stop"

$DotfilesDir = Split-Path $PSScriptRoot
$ExtensionsFile = Join-Path $PSScriptRoot "vscode_extensions.txt"

# =======================
# 1. VS Code extensions
# =======================

$UrlRoot = "https://marketplace.visualstudio.com"

function Get-ExtensionParts {
    param([string]$Entry)
    if ($Entry -match "^(.+)@(.+)$") {
        $ExtensionId = $Matches[1]
        $PinnedVersion = $Matches[2]
    } else {
        $ExtensionId = $Entry
        $PinnedVersion = ""
    }
    $Publisher, $Package = $ExtensionId -split '\.', 2
    return @{
        ExtensionId = $ExtensionId
        Publisher = $Publisher
        Package = $Package
        PinnedVersion = $PinnedVersion
    }
}

function Download-VSCodeExtension {
    param([string]$Entry)

    $ext = Get-ExtensionParts $Entry
    $UrlVersion = if ($ext.PinnedVersion) { $ext.PinnedVersion } else { "latest" }
    $VsixFile = Join-Path $env:TEMP "$($ext.Publisher).$($ext.Package)-$UrlVersion.vsix"
    $Url = "$UrlRoot/_apis/public/gallery/publishers/$($ext.Publisher)/vsextensions/$($ext.Package)/$UrlVersion/vspackage"

    try {
        Invoke-WebRequest -Uri $Url -OutFile $VsixFile -UseBasicParsing
        Write-Host "  Downloaded $($ext.ExtensionId)@$UrlVersion" -ForegroundColor Green
        return $VsixFile
    } catch {
        Write-Host "  [ERROR] Failed to download $($ext.ExtensionId)@$UrlVersion" -ForegroundColor Red
        return $null
    }
}

function Install-VSCodeExtension {
    param([string]$Entry)

    $ext = Get-ExtensionParts $Entry

    if ($ext.PinnedVersion) {
        # Pinned version: download vsix and install from file
        $VsixFile = Download-VSCodeExtension $Entry
        if ($VsixFile) {
            code --install-extension $VsixFile --force 2>$null
            Write-Host "  Installed $($ext.ExtensionId)@$($ext.PinnedVersion) (from vsix)" -ForegroundColor Green
        }
    } else {
        # Latest version: let code CLI handle it
        $Output = code --install-extension $ext.ExtensionId --force 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  Installed $($ext.ExtensionId)" -ForegroundColor Green
        } else {
            Write-Host "  [ERROR] Failed to install $($ext.ExtensionId)" -ForegroundColor Red
        }
    }
}

function Get-Extensions {
    Get-Content $ExtensionsFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#")) { $line }
    }
}

Write-Host "Installing VS Code extensions..." -ForegroundColor Cyan

$InstallArgs = @()
Get-Extensions | ForEach-Object {
    $ext = Get-ExtensionParts $_
    if ($ext.PinnedVersion) {
        # Pinned version: download vsix first
        $VsixFile = Download-VSCodeExtension $_
        if ($VsixFile) { $InstallArgs += @("--install-extension", $VsixFile) }
    } else {
        # Latest version: let code handle the download
        $InstallArgs += @("--install-extension", $ext.ExtensionId)
    }
}

if ($InstallArgs) {
    code @InstallArgs --force 2>$null
    Write-Host "Done." -ForegroundColor Cyan
} else {
    Write-Host "No extensions to install." -ForegroundColor Yellow
}
