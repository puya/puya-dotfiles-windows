<#
.SYNOPSIS
    Main PowerShell Profile
.DESCRIPTION
    This is the main entry point for the PowerShell profile.
    It sources other modular configuration files and initializes the environment.
#>

# --- Define the location of the modular profile files ---
# This logic is robustly designed to find the true path of the script,
# even when the profile is loaded via a symbolic link.
$ProfilePath = $MyInvocation.MyCommand.Definition
$ProfileItem = Get-Item -LiteralPath $ProfilePath
if ($ProfileItem.LinkType -eq 'SymbolicLink') {
    # It's a symlink, so we get the directory of the link's target.
    $PSScriptRoot = Split-Path -Parent -Path $ProfileItem.Target
} else {
    # It's a regular file, so we use its own directory.
    $PSScriptRoot = Split-Path -Parent -Path $ProfilePath
}

# Load optional files
$OptionalScripts = @(
    "$PSScriptRoot/01-environment.ps1",
    "$PSScriptRoot/10-aliases.ps1"
)

foreach ($script in $OptionalScripts) {
    if (Test-Path $script) {
        . $script
    }
}

# mise activation
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Invoke-Expression -Command (mise activate pwsh | Out-String)
}

# --- Initialize Oh My Posh ---
# This makes the prompt look nice. It should be the very last thing to run.
if ($Host.Name -eq 'ConsoleHost' -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    oh-my-posh init pwsh --config '$env:POSH_THEMES_PATH\jandedobbeleer.omp.json' | Invoke-Expression
    Write-Host "✅ PowerShell profile loaded." -ForegroundColor Green
} 