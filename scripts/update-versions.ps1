<#
.SYNOPSIS
    Updates the .tool-versions file to the latest stable releases using mise.
.DESCRIPTION
    This script reads the .tool-versions file in the project root, checks for the
    latest stable version of each tool (with special handling for Python and Node.js),
    and updates the file in-place if a newer version is found.
#>

# -----------------------------------------------------------------------------
# --- Script Setup ---
# -----------------------------------------------------------------------------

# Exit on any error
$ErrorActionPreference = "Stop"

$ToolVersionsFile = Join-Path -Path $PSScriptRoot -ChildPath "..\.tool-versions"

if (-not (Test-Path $ToolVersionsFile)) {
    Write-Host "❌ Error: .tool-versions file not found at '$ToolVersionsFile'." -ForegroundColor Red
    exit 1
}

# --- Helper to check if a command exists ---
function Test-CommandExists {
    param([string]$command)
    return [bool](Get-Command $command -ErrorAction SilentlyContinue)
}

if (-not (Test-CommandExists "mise")) {
    Write-Host "❌ Error: 'mise' command not found. Please ensure it is installed and in your PATH." -ForegroundColor Red
    exit 1
}

Write-Host "🔄 Checking for updates for tools in $ToolVersionsFile..." -ForegroundColor Cyan

# -----------------------------------------------------------------------------
# --- Main Update Logic ---
# -----------------------------------------------------------------------------

$updatesMade = $false

# Read the .tool-versions file, skipping comments and empty lines
$lines = Get-Content $ToolVersionsFile
$newLines = @()

foreach ($line in $lines) {
    if ($line -match "^\s*#" -or -not $line.Trim()) {
        $newLines += $line
        continue
    }

    $parts = $line.Trim() -split "\s+"
    $tool = $parts[0]
    $currentVersion = $parts[1]
    
    Write-Host "`nChecking '$tool'..." -ForegroundColor Yellow
    
    $latestVersion = ""

    try {
        if ($tool -eq "nodejs") {
            Write-Host "  -> Finding latest LTS version..."
            $latestVersion = (mise latest nodejs lts).Trim()
        } elseif ($tool -eq "python") {
            Write-Host "  -> Finding latest stable, non-experimental version..."
            # Get all stable versions (e.g., 3.10.1, 3.11.5, 3.12.3)
            $allStableVersions = mise list-all python | Where-Object { $_ -match "^\d+\.\d+\.\d+$" }
            # Get the major.minor series (e.g., 3.10, 3.11, 3.12)
            $allSeries = $allStableVersions | ForEach-Object { ($_.Split('.')[0..1]) -join '.' } | Select-Object -Unique | Sort-Object -Property @{Expression={[version]$_}}
            # Target the second-to-last series
            $targetSeries = $allSeries[-2]
            # Find the latest patch release within that series
            $latestVersion = ($allStableVersions | Where-Object { $_.StartsWith("$targetSeries.") } | Sort-Object -Property @{Expression={[version]$_}})[-1].Trim()
        } else {
            Write-Host "  -> Finding latest stable version..."
            $latestVersion = (mise latest $tool).Trim()
        }
    } catch {
        Write-Host "  -> ⚠️ Could not determine latest version for '$tool'. Skipping." -ForegroundColor Magenta
        $newLines += $line
        continue
    }

    if ($latestVersion -eq $currentVersion) {
        Write-Host "  -> ✅ You already have the latest version: $currentVersion" -ForegroundColor Green
        $newLines += $line
    } else {
        Write-Host "  -> ✨ Found new version: $latestVersion (current: $currentVersion)" -ForegroundColor Green
        $newLines += "$tool $latestVersion"
        $updatesMade = $true
    }
}

# -----------------------------------------------------------------------------
# --- Finalize ---
# -----------------------------------------------------------------------------

if ($updatesMade) {
    Write-Host "`n💾 Updates were made. Saving changes to $ToolVersionsFile..." -ForegroundColor Cyan
    Set-Content -Path $ToolVersionsFile -Value $newLines
    Write-Host "✅ All tools checked. Run 'mise install' to install the new versions." -ForegroundColor Cyan
} else {
    Write-Host "`n✅ All tools are already up-to-date." -ForegroundColor Green
} 