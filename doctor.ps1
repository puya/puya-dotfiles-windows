<#
.SYNOPSIS
    Windows Environment Health Checker
.DESCRIPTION
    This script validates the entire development environment setup, checking for
    correct installation and configuration of tools, packages, and authentication.
#>
$ErrorActionPreference = "SilentlyContinue"

# -----------------------------------------------------------------------------
# --- Helper Functions for Output ---
# -----------------------------------------------------------------------------

function Write-SectionHeader {
    param([string]$Title)
    Write-Host "`n"
    Write-Host "--- $Title ---" -ForegroundColor Cyan
}

function Write-Check {
    param(
        [string]$CheckName,
        [bool]$Success,
        [string]$Details = ""
    )
    if ($Success) {
        Write-Host "✅" -ForegroundColor Green -NoNewline
        Write-Host " $CheckName"
    } else {
        Write-Host "❌" -ForegroundColor Red -NoNewline
        Write-Host " $CheckName"
    }
    if ($Details) {
        Write-Host "   -> $Details"
    }
}

# -----------------------------------------------------------------------------
# --- Main Doctor Script ---
# -----------------------------------------------------------------------------

Write-SectionHeader "🩺 Puya's Windows Dotfiles Doctor"

# --- System Information ---
Write-SectionHeader "💻 System Information"
$os = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Check "Operating System" $true "$($os.Caption) $($os.Version)"
Write-Check "PowerShell Version" $true $PSVersionTable.PSVersion

# --- Package Manager: Scoop ---
Write-SectionHeader "📦 Package Manager: Scoop"
$scoopCheck = Get-Command scoop -ErrorAction SilentlyContinue
Write-Check "Scoop Installed" ($null -ne $scoopCheck)
if ($scoopCheck) {
    # Check for a few key apps
    $gitCheck = Get-Command git -ErrorAction SilentlyContinue
    Write-Check "Git available via Scoop" ($null -ne $gitCheck)
    $ghCheck = Get-Command gh -ErrorAction SilentlyContinue
    Write-Check "GitHub CLI (gh) available via Scoop" ($null -ne $ghCheck)
}

# --- Version Manager: mise ---
Write-SectionHeader "🔧 Version Manager: mise"
$miseCheck = Get-Command mise -ErrorAction SilentlyContinue
Write-Check "mise Installed" ($null -ne $miseCheck)
if ($miseCheck) {
    $miseCurrent = mise current
    Write-Check "mise can report current tools" ($LASTEXITCODE -eq 0) $miseCurrent
    # Check for poetry via pipx
    $poetryCheck = Get-Command poetry -ErrorAction SilentlyContinue
    Write-Check "Poetry available via pipx" ($null -ne $poetryCheck)
}

# --- Dotfiles Linking ---
Write-SectionHeader "🔗 Dotfiles Linking"
$profilePath = $PROFILE
$profileLink = Get-Item $profilePath -ErrorAction SilentlyContinue
$dotfilesProfile = Join-Path -Path $PSScriptRoot -ChildPath "powershell\profile.ps1"
# Resolve the full path for comparison to avoid relative path issues
$expectedTarget = (Resolve-Path $dotfilesProfile).Path
$actualTarget = (Resolve-Path $profileLink.Target).Path
$isLinked = ($profileLink.LinkType -eq "SymbolicLink" -and $actualTarget -eq $expectedTarget)
Write-Check "PowerShell Profile is correctly linked" $isLinked "Target: $($profileLink.Target)"

# --- Authentication ---
Write-SectionHeader "🔐 Authentication"
# 1Password CLI
$opCheck = Get-Command op -ErrorAction SilentlyContinue
Write-Check "1Password CLI (op) Installed" ($null -ne $opCheck)
if ($opCheck) {
    op account list | Out-Null
    Write-Check "1Password CLI is signed in" ($LASTEXITCODE -eq 0)
}
# 1Password SSH Agent
$sshKeys = ssh-add -L
Write-Check "1Password SSH Agent has keys loaded" ($null -ne $sshKeys)
# Git Signing
# We must check the .local file directly, as 'git config --get' can inherit the placeholder.
$gitConfigLocalPath = Join-Path $HOME ".gitconfig.local"
$signingKey = ""
if (Test-Path $gitConfigLocalPath) {
    $signingKey = Select-String -Path $gitConfigLocalPath -Pattern "signingkey" | Select-Object -First 1
}
$isKeySet = (-not [string]::IsNullOrWhiteSpace($signingKey) -and $signingKey -notmatch "YOUR_SSH_PUBLIC_KEY_HERE")
Write-Check "Git signingkey is set in .gitconfig.local" $isKeySet
# GitHub CLI
$ghAuth = gh auth status
Write-Check "GitHub CLI is authenticated" ($LASTEXITCODE -eq 0)

Write-Host "`n"
Write-Check "Doctor summary: Review any items marked with ❌" -Success ($LASTEXITCODE -eq 0) 