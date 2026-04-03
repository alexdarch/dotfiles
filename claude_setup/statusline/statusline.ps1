# Claude Code statusline - reads JSON from stdin
# Line 1: [time magenta] model (blue) | path (dark blue) [git light blue]
# Line 2: context bar (green/orange/red) with tokens | cost (yellow)
# IMPORTANT: invoke with -NoProfile to avoid slow startup

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Json = [Console]::In.ReadToEnd()
$Data = $Json | ConvertFrom-Json

# ANSI escape codes
$Esc = [char]0x1b
$Reset = "$Esc[0m"
$DarkBlue = "$Esc[38;5;33m"
$LightBlue = "$Esc[38;5;117m"
$ModelBlue = "$Esc[38;5;75m"
$Magenta = "$Esc[38;5;170m"
$Green = "$Esc[38;5;78m"
$Yellow = "$Esc[38;5;214m"
$Red = "$Esc[38;5;196m"
$Dim = "$Esc[2m"

# --- Line 1: [time] model | path [git] ---
$Dir = Split-Path -Leaf $Data.cwd

$GitInfo = ""
if ($Data.cwd -and (Test-Path (Join-Path $Data.cwd ".git"))) {
    $Branch = git --no-optional-locks -C $Data.cwd branch --show-current 2>$null
    $Dirty = ""
    git --no-optional-locks -C $Data.cwd diff --quiet 2>$null
    if ($LASTEXITCODE -ne 0) { $Dirty = "*" }
    git --no-optional-locks -C $Data.cwd diff --cached --quiet 2>$null
    if ($LASTEXITCODE -ne 0) { $Dirty += "+" }
    if ($Branch) { $GitInfo = " ${LightBlue}$Branch$Dirty${Reset}" }
}

$Model = $Data.model.display_name
$ModelPart = ""
if ($Model) { $ModelPart = " ${ModelBlue}$Model${Reset}" }

$Time = Get-Date -Format "HH:mm"

Write-Output "${Dim}[${Reset}${Magenta}$Time${Reset}$ModelPart${Dim}]${Reset} ${DarkBlue}$Dir${Reset}$GitInfo"

# --- Line 2: context bar with tokens | cost ---
$BarWidth = 20
$UsedPct = $Data.context_window.used_percentage
$WindowSize = $Data.context_window.context_window_size

if ($null -ne $UsedPct) {
    $Pct = [math]::Round([double]$UsedPct)

    # Color based on usage
    if ($Pct -lt 30) { $BarColor = $Green }
    elseif ($Pct -lt 70) { $BarColor = $Yellow }
    else { $BarColor = $Red }

    $Filled = [math]::Round($BarWidth * $Pct / 100)
    $Empty = $BarWidth - $Filled
    $FilledBar = ([string][char]0x2588) * $Filled
    $EmptyBar = ([string][char]0x2591) * $Empty
    $Bar = "${BarColor}${FilledBar}${Dim}${EmptyBar}${Reset}"

    # Derive current token usage from percentage and window size
    if ($null -ne $WindowSize) {
        $MaxTokens = [double]$WindowSize
        $UsedTokens = [math]::Round($MaxTokens * [double]$UsedPct / 100)
        $TokensUsed = "{0:N0}k" -f [math]::Round($UsedTokens / 1000)
        $TokensMax = "{0:N0}k" -f [math]::Round($MaxTokens / 1000)
    } else {
        $TokensUsed = "?"
        $TokensMax = "?"
    }

    $CtxLine = "${BarColor}ctx:${Reset} $Bar ${BarColor}${Pct}%${Reset} ${Dim}${TokensUsed} / ${TokensMax}${Reset}"
} else {
    $EmptyBar = ([string][char]0x2591) * $BarWidth
    $CtxLine = "${Dim}ctx: ${EmptyBar} -%${Reset}"
}

$Cost = $Data.cost.total_cost_usd
if ($null -ne $Cost) {
    $CostStr = "`$$([math]::Round([double]$Cost, 2).ToString('0.00'))"
    $CtxLine = "$CtxLine ${Dim}|${Reset} ${Yellow}$CostStr${Reset}"
}

Write-Output $CtxLine
