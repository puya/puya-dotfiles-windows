<#
.SYNOPSIS
    Links the dotfiles to their proper locations.
.DESCRIPTION
    This script creates symbolic links from the system's configuration file locations
    to the files managed in this dotfiles repository.
#>

# Define paths
$DotfilesRoot = $PSScriptRoot | Split-Path -Parent

# Helper function for logging
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $FormattedMessage = "[$Timestamp] [$Level] $Message"
    Write-Output $FormattedMessage
}

function Link-Dotfile {
    param(
        [string]$Source,
        [string]$Destination
    )

    Write-Log "Attempting to link '$Source'..."
    Write-Log "Destination: '$Destination'"

    # Ensure the destination directory exists
    $DestinationDir = Split-Path -Path $Destination -Parent
    if (-not (Test-Path $DestinationDir)) {
        Write-Log "Destination directory does not exist. Creating it..."
        New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
    }

    # Check if a file or link already exists at the destination
    if (Test-Path $Destination) {
        # Check if it's already a symlink to our source file
        $ExistingLink = Get-Item -Path $Destination -ErrorAction SilentlyContinue
        if ($ExistingLink.LinkType -eq "SymbolicLink" -and $ExistingLink.Target -eq $Source) {
            Write-Log "✅ '$Source' is already correctly linked. Skipping."
        } else {
            # Backup existing file
            $BackupPath = "$Destination.bak.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Write-Log "Existing file found. Backing it up to '$BackupPath'"
            Move-Item -Path $Destination -Destination $BackupPath -Force
            
            # Create the new symlink
            Write-Log "Creating new symbolic link for '$Source'..."
            New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
            Write-Log "✅ '$Source' successfully linked."
        }
    } else {
        # No existing file, just create the link
        Write-Log "No existing file found. Creating new symbolic link..."
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source -Force | Out-Null
        Write-Log "✅ '$Source' successfully linked."
    }
}

function Cleanup-OldBackups {
    param([string]$Directory)
    $BackupFiles = Get-ChildItem -Path $Directory -Filter "*.bak.*"
    if ($BackupFiles) {
        Write-Log "🧹 Found old backups in '$Directory'. Cleaning them up..."
        foreach ($File in $BackupFiles) {
            Write-Log " -> Removing $($File.Name)"
            Remove-Item -Path $File.FullName -Force
        }
    }
}

Write-Log "🔗 Starting dotfile linking process..."

# --- Clean up any old backups from previous runs ---
Cleanup-OldBackups -Directory (Split-Path -Path $PROFILE -Parent)
Cleanup-OldBackups -Directory $HOME


# --- Link PowerShell Profile ---
$SourceProfile = Join-Path -Path $DotfilesRoot -ChildPath "powershell\profile.ps1"
$DestinationProfile = $PROFILE
Link-Dotfile -Source $SourceProfile -Destination $DestinationProfile

# --- Link Git Configuration ---
$SourceGitConfig = Join-Path -Path $DotfilesRoot -ChildPath ".gitconfig"
$DestinationGitConfig = Join-Path -Path $HOME -ChildPath ".gitconfig"
Link-Dotfile -Source $SourceGitConfig -Destination $DestinationGitConfig


Write-Log "🔗 Dotfile linking process complete." 