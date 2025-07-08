<#
.SYNOPSIS
    GitHub CLI Authentication Setup Helper for 1Password on Windows
.DESCRIPTION
    This script helps you configure GitHub CLI with 1Password for secure authentication.
#>
$ErrorActionPreference = "Stop"

# --- Helper function for colored output ---
function Write-Color {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

Write-Color "🐙 GitHub CLI Authentication Setup" -Color Cyan
Write-Color "---------------------------------" -Color Cyan

# --- Check Prerequisites ---
Write-Color "\n🔍 Checking Prerequisites..." -Color Yellow
$prereqsMet = $true
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Color "❌ GitHub CLI (gh) is not installed. Please run the main init.ps1 script." -Color Red
    $prereqsMet = $false
} else {
    Write-Color "✅ GitHub CLI is installed." -Color Green
}

if (-not (Get-Command op -ErrorAction SilentlyContinue)) {
    Write-Color "❌ 1Password CLI is not installed. Please run the main init.ps1 script." -Color Red
    $prereqsMet = $false
} else {
    Write-Color "✅ 1Password CLI is installed." -Color Green
}

if (-not $prereqsMet) { exit 1 }

# --- Check 1Password Sign-in Status ---
try {
    op account list | Out-Null
    Write-Color "✅ 1Password CLI is signed in." -Color Green
}
catch {
    Write-Color "❌ 1Password CLI is not signed in. Please run 'op signin' first." -Color Red
    exit 1
}

# --- Check Current GitHub CLI Status ---
Write-Color "\n🤔 Checking current GitHub CLI status..." -Color Yellow
$authStatus = gh auth status -t 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Color "✅ GitHub CLI is already authenticated." -Color Green
    Write-Host $authStatus
    $reconfigure = Read-Host -Prompt "Do you want to reconfigure authentication anyway? (y/N)"
    if ($reconfigure.ToLower() -ne 'y') {
        Write-Color "⏭️  Keeping existing configuration. Exiting." -Color Cyan
        exit 0
    }
} else {
    Write-Color "ℹ️  GitHub CLI is not currently authenticated." -Color Blue
}

# --- Authentication Guidance ---
Write-Color "\n🔐 Starting Authentication Process..." -Color Yellow
Write-Color "On Windows, the recommended method is to authenticate with an SSH key from your 1Password SSH Agent."
Write-Color "You will be prompted to select your preferred protocol. Please choose 'SSH'."
Write-Color "You will also be asked to log in with a web browser to grant the necessary permissions."

Read-Host -Prompt "`n✅ Press [Enter] to begin 'gh auth login'..."

# --- Run GitHub Auth Login ---
try {
    gh auth login -p ssh -w
    Write-Color "\n✅ GitHub CLI authentication process completed." -Color Green
}
catch {
    Write-Color "\n❌ An error occurred during 'gh auth login'." -Color Red
    Write-Color $_.Exception.Message
    exit 1
}

# --- Final Verification ---
Write-Color "\n🩺 Verifying final authentication status..." -Color Yellow
$finalStatus = gh auth status -t
if ($LASTEXITCODE -eq 0) {
    Write-Color "🎉 Success! You are logged into GitHub." -Color Green
    Write-Host $finalStatus
} else {
    Write-Color "⚠️  Authentication still seems to have failed. Please review the output above." -Color Red
    Write-Host $finalStatus
} 