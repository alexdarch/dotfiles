function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function prompt {
    # https://github.com/dahlbyk/posh-git/wiki/Customizing-Your-PowerShell-Prompt
    $origLastExitCode = $LastExitCode
    $vcs_status = "$(Write-VcsStatus)"

    if (Test-Administrator) {  # if elevated
        Write-Host "(Elevated) " -NoNewline -ForegroundColor White
    }

    Write-Host "$env:USERNAME@" -NoNewline -ForegroundColor DarkYellow
    Write-Host "$env:COMPUTERNAME" -NoNewline -ForegroundColor Magenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray

    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curPath.ToLower().StartsWith($Home.ToLower()))
    {
        $curPath = $(Get-Location)  # $Home + $curPath.SubString($Home.Length)
    }
    write-Host $curPath -NoNewline -ForegroundColor Blue

    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host (Get-Date -Format G) -NoNewline -ForegroundColor DarkMagenta
    Write-Host " : " -NoNewline -ForegroundColor DarkGray
    Write-Host $vcs_status 
    
    # start a newline
    if (Test-Path env:VIRTUAL_ENV) {
        Write-Host "(venv) " -NoNewline
    }

    $LastExitCode = $origLastExitCode
    "$('>' * ($nestedPromptLevel + 1)) "
}

Import-Module -Name posh-git
# Import-Module -Name PSVirtualEnv  # requires powershell v6+
Import-Module posh-sshell
Start-SshAgent
Import-Module Get-ChildItemColor
Set-Alias ls Get-ChildItemColor -option AllScope -Force
Set-Alias dir Get-ChildItemColor -option AllScope -Force
Write-Host "Importing posh-git and Get-ChildItemColor. Starting SshAgent"

$global:GitPromptSettings.BeforeStatus = '['
$global:GitPromptSettings.AfterStatus  = '] '
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Add uv
$env:Path = "C:\Users\alexd\.local\bin;$env:Path"
