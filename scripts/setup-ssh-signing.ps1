<#
.SYNOPSIS
    SSH Signing Setup Helper for 1Password on Windows
.DESCRIPTION
    This script helps you configure Git commit signing with the 1Password SSH agent.
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

Write-Color "🔐 SSH Signing Setup for 1Password" -Color Cyan
Write-Color "-------------------------------------" -Color Cyan

# --- Check Prerequisites ---
Write-Color "🔍 Checking for 1Password SSH Agent..." -Color Yellow
try {
    $keys = ssh-add -L
    if ($null -eq $keys) { throw }
    Write-Color "✅ 1Password SSH Agent is running and has keys." -Color Green
}
catch {
    Write-Color "❌ No SSH keys found in 1Password agent." -Color Red
    Write-Color "   Please ensure:"
    Write-Color "   1. The 1Password desktop app is running and unlocked."
    Write-Color "   2. The SSH agent is enabled in 1Password Settings > Developer."
    Write-Color "   3. You have at least one SSH key stored in your 1Password vault."
    exit 1
}

# --- Select Signing Key ---
Write-Color "\n📝 Please select the SSH key you want to use for signing Git commits:" -Color Yellow
$keyArray = $keys | ForEach-Object { $_ }
for ($i = 0; $i -lt $keyArray.Length; $i++) {
    Write-Color "  [$($i+1)] $($keyArray[$i])"
}

$choice = Read-Host -Prompt "`nEnter the number of the key to use"
$index = $choice -as [int]

if ($null -eq $index -or $index -lt 1 -or $index -gt $keyArray.Length) {
    Write-Color "❌ Invalid selection. Please enter a number from the list." -Color Red
    exit 1
}

$selectedKey = $keyArray[$index-1]
Write-Color "✅ You selected: $selectedKey" -Color Green

# --- Update Git Configuration ---
$GitConfigLocalPath = Join-Path -Path $HOME -ChildPath ".gitconfig.local"

if (-not (Test-Path $GitConfigLocalPath)) {
    Write-Color "🤔 ~/.gitconfig.local not found. It's recommended to run the main init.ps1 script first." -Color Yellow
    Write-Color "   Creating a new ~/.gitconfig.local file..." -Color Yellow
    $ExampleGitConfig = Join-Path -Path $PSScriptRoot -ChildPath "..\gitconfig.local.example"
    if (Test-Path $ExampleGitConfig) {
        Copy-Item -Path $ExampleGitConfig -Destination $GitConfigLocalPath
    } else {
        Write-Color "❌ Could not find gitconfig.local.example to create a new file." -Color Red
        exit 1
    }
}

Write-Color "\n🔄 Updating signingkey in $GitConfigLocalPath..." -Color Yellow
try {
    # Escape characters that have special meaning in regex
    $escapedKey = [regex]::Escape($selectedKey)
    (Get-Content $GitConfigLocalPath) | ForEach-Object {
        $_ -replace '(^\s*signingkey\s*=\s*).*$', "`$1$selectedKey"
    } | Set-Content $GitConfigLocalPath
    
    Write-Color "✅ Successfully updated the signing key." -Color Green
}
catch {
    Write-Color "❌ An error occurred while updating the git config." -Color Red
    Write-Color $_.Exception.Message
    exit 1
}

Write-Color "\n🎉 Setup Complete!" -Color Cyan
Write-Color "Your Git signing is now configured with 1Password."
Write-Color "• Test by creating a commit in a repository."
Write-Color "• Verify with: git log --show-signature -1" 