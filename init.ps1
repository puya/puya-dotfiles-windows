<#
.SYNOPSIS
    Puya's Dotfiles for Windows - Main Setup Script

.DESCRIPTION
    This script automates the setup of a complete development environment on a new
    Windows machine. It handles package installation via Scoop, tool versioning via
    mise, and PowerShell profile configuration.

.NOTES
    Author: Puya Khalili
    Version: 1.0
#>

# -----------------------------------------------------------------------------
# --- Script Configuration & Helper Functions ---
# -----------------------------------------------------------------------------

# --- State Tracking ---
$ScriptHasErrored = $false

# Check for Administrator privileges and self-elevate if necessary
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "Administrator privileges are required."
    Write-Warning "Requesting elevation... Please approve the UAC prompt."
    
    # Relaunch the script with Admin rights and keep the window open
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoExit -NoProfile -File `"$PSCommandPath`""
    exit
}


# Set strict mode
Set-StrictMode -Version Latest
# Exit on any error
$ErrorActionPreference = "Stop"

# Define important paths
$DotfilesRoot = $PSScriptRoot
$ScriptsDir = Join-Path -Path $DotfilesRoot -ChildPath "scripts"
$PowerShellDir = Join-Path -Path $DotfilesRoot -ChildPath "powershell"
$LogDir = Join-Path -Path $DotfilesRoot -ChildPath "logs"
$LogFile = Join-Path -Path $LogDir -ChildPath "setup.log"

# Ensure log directory exists
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# Helper function for logging
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $FormattedMessage = "[$Timestamp] [$Level] $Message"

    if ($Level -eq "ERROR") {
        $global:ScriptHasErrored = $true
    }

    # Write to console
    Write-Output $FormattedMessage
    # Append to log file
    Add-Content -Path $LogFile -Value $FormattedMessage
}

# --- Function to Install Scoop ---
function Install-Scoop {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Log "Scoop is already installed."
    } else {
        Write-Log "Scoop not found. Installing..."
        # Set execution policy to allow script execution for the current process
        Set-ExecutionPolicy RemoteSigned -Scope Process -Force
        # Download and install Scoop
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
        Write-Log "✅ Scoop installed successfully."
    }
}

# --- Function to Install Apps from Scoopfile ---
function Install-ScoopApps {
    Write-Log "Installing applications from scoopfile.json..."
    $Scoopfile = Join-Path -Path $DotfilesRoot -ChildPath "scoopfile.json"
    if (-not (Test-Path $Scoopfile)) {
        Write-Log "scoopfile.json not found. Skipping app installation." -Level "WARN"
        return
    }

    # Git is now a prerequisite installed via winget. We no longer need to install it here.
    # Scoop will automatically find and use the system's Git for managing buckets.

    try {
        # The 'directory' command requires the 'extras' bucket
        Write-Log "Adding scoop 'extras' bucket..."
        scoop bucket add extras
    } catch {
        Write-Log "Could not add 'extras' bucket (maybe it already exists)."
    }

    try {
        # Import the scoopfile to install all apps
        Write-Log "Reading app list from scoopfile.json..."
        $ScoopAppList = (Get-Content -Raw -Path $Scoopfile | ConvertFrom-Json).apps
        
        if ($null -eq $ScoopAppList) {
            Write-Log "No apps found in scoopfile.json. Skipping." -Level "WARN"
            return
        }

        Write-Log "Installing $($ScoopAppList.Count) apps..."
        scoop install $ScoopAppList

        Write-Log "✅ Successfully installed apps from scoopfile."

        # IMPORTANT: Permanently add Scoop to the user's PATH
        $ScoopShimPath = "$env:USERPROFILE\scoop\shims"
        $UserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
        if ($UserPath -notlike "*$ScoopShimPath*") {
            Write-Log "Adding Scoop to persistent user PATH..."
            $NewPath = "$UserPath;$ScoopShimPath"
            [System.Environment]::SetEnvironmentVariable("Path", $NewPath, "User")
            Write-Log "✅ Scoop PATH set. You may need to open a new terminal for it to take effect."
        } else {
            Write-Log "Scoop is already in the user PATH."
        }

        # IMPORTANT: Reload the environment variables to make new commands available
        Write-Log "Reloading environment variables..."
        $env:PATH = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        Write-Log "✅ Environment reloaded."
    } catch {
        Write-Log "An error occurred while installing apps from scoopfile." -Level "ERROR"
        Write-Log $_.Exception.Message -Level "ERROR"
    }
}

# --- Function to Install Tool Versions with mise ---
function Install-ToolVersions {
    Write-Log "Installing tool versions with mise..."
    # mise needs to be in the PATH. Scoop should handle this.
    if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
        Write-Log "'mise' command not found. Please ensure Scoop has added it to your PATH." -Level "ERROR"
        Write-Log "You may need to restart your PowerShell session." -Level "ERROR"
        return
    }

    # Clean up the broken poetry plugin if it exists
    if (mise plugins ls | Select-String -Quiet "poetry") {
        Write-Log "Removing broken 'poetry' plugin from mise..." -Level "WARN"
        mise plugins uninstall poetry
    }

    try {
        # 'mise install' will automatically read the .tool-versions file in the current directory
        mise install --yes
        Write-Log "✅ Successfully installed tool versions defined in .tool-versions"

        # Set all installed tools as global defaults
        Write-Log "Setting installed tools as global defaults..."
        $ToolVersionsFile = Join-Path -Path $DotfilesRoot -ChildPath ".tool-versions"
        if (Test-Path $ToolVersionsFile) {
            Get-Content $ToolVersionsFile | ForEach-Object {
                if ($_ -match "(\S+)\s+(\S+)") {
                    $tool = $matches[1]
                    $version = $matches[2]
                    Write-Log "Setting $tool@$version as global..."
                    mise use --global "$tool@$version"
                }
            }
            Write-Log "✅ Global tool versions set."
        } else {
            Write-Log ".tool-versions file not found, skipping setting globals." -Level "WARN"
        }

    } catch {
        Write-Log "An error occurred while installing tool versions with mise." -Level "ERROR"
        Write-Log $_.Exception.Message -Level "ERROR"
    }
}

# --- Function to Install Python tools with pipx ---
function Install-PipxTools {
    Write-Log "Installing global Python tools with pipx..."

    # --- Comprehensive pipx cleanup ---
    Write-Log "Performing cleanup of any previous pipx installations..."
    
    # Path to the pipx user data directory (default)
    $PipxHomeDefault = Join-Path $env:USERPROFILE ".local/pipx"
    if (Test-Path $PipxHomeDefault) {
        Write-Log "Removing old pipx home directory: $PipxHomeDefault" -Level "WARN"
        Remove-Item -Recurse -Path $PipxHomeDefault -Force
    }
    
    # Path to alternate pipx user data directory (seen in logs)
    $PipxHomeAlt = Join-Path $env:USERPROFILE "pipx"
    if (Test-Path $PipxHomeAlt) {
        Write-Log "Removing alternate pipx home directory: $PipxHomeAlt" -Level "WARN"
        Remove-Item -Recurse -Path $PipxHomeAlt -Force
    }

    # Path to the user's local bin where pipx might put shims
    $UserLocalBin = Join-Path $env:USERPROFILE ".local/bin"
    if (Test-Path $UserLocalBin) {
        Get-ChildItem -Path $UserLocalBin -Filter "pipx.exe" | ForEach-Object {
            Write-Log "Removing stale pipx launcher from: $($_.FullName)" -Level "WARN"
            Remove-Item -Path $_.FullName -Force
        }
    }

    # Path to the Python user scripts directory (often the culprit)
    $PythonUserScripts = Join-Path ([System.Environment]::GetFolderPath('ApplicationData')) "Python"
    if (Test-Path $PythonUserScripts) {
        Get-ChildItem -Path $PythonUserScripts -Recurse -Filter "pipx.exe" | ForEach-Object {
            Write-Log "Removing stale pipx launcher from: $($_.FullName)" -Level "WARN"
            Remove-Item -Path $_.FullName -Force
        }
    }
    # --- End Cleanup ---

    if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Log "Python not found even after mise activation. Cannot install pipx tools. Skipping." -Level "WARN"
        return
    }

    try {
        # Ensure pipx is installed using the Python from mise
        Write-Log "Ensuring pipx is available..."
        python -m pip install --user pipx
        python -m pipx ensurepath

        # Install uv by calling pipx through the python module.
        # This is more reliable than depending on the PATH being updated mid-script.
        
        # Get list of currently installed pipx packages to ensure idempotency
        $InstalledPipxPackages = python -m pipx list

        if ($InstalledPipxPackages -notmatch "uv") {
            Write-Log "Installing 'uv' with pipx..."
            python -m pipx install uv
            Write-Log "✅ Successfully installed 'uv'."
        } else {
            Write-Log "✅ 'uv' is already installed via pipx. Skipping."
        }

        if ($InstalledPipxPackages -notmatch "poetry") {
            Write-Log "Installing 'poetry' with pipx..."
            python -m pipx install poetry
            Write-Log "✅ Successfully installed 'poetry'."
        } else {
            Write-Log "✅ 'poetry' is already installed via pipx. Skipping."
        }
    } catch {
        Write-Log "An error occurred while installing pipx tools." -Level "ERROR"
        Write-Log $_.Exception.Message -Level "ERROR"
    }
}

Write-Log "🚀 Starting Windows dotfiles setup..."

# -----------------------------------------------------------------------------
# --- Main Setup Steps (To be implemented) ---
# -----------------------------------------------------------------------------

# 1. Install Scoop (if not already installed)
#    - This will be the primary package manager.
Write-Log "Step 1: Package Management (Scoop)..."
Install-Scoop


# 2. Install packages from Scoopfile
#    - Uses the 'scoopfile.json' to install all required CLI tools.
Write-Log "Step 2: Installing packages from Scoopfile..."
Install-ScoopApps


# 3. Install mise (the version manager)
#    - 'mise' is installed via Scoop in the previous step.
Write-Log "Step 3: Version Management (mise)..."
# We just need to ensure it's on the path, which Scoop handles.
# The actual installation of tools happens after linking.


# 4. Link dotfiles to their correct locations
#    - This will symlink the PowerShell profile and other configs.
Write-Log "Step 4: Linking configuration files..."
. (Join-Path -Path $ScriptsDir -ChildPath "link-dotfiles.ps1")


# 5. Install tool versions with mise
#    - Reads '.tool-versions' and installs the specified tools.
Write-Log "Step 5: Installing tool versions with mise..."
Install-ToolVersions

# ACTIVATE MISE to make tools available for the rest of the script
Write-Log "Activating mise shims for current session..."
try {
    # Use hook-env for scripting, which is more reliable than 'activate'
    mise hook-env -s pwsh | Invoke-Expression
    Write-Log "✅ mise activated."
} catch {
    Write-Log "Could not activate mise." -Level "ERROR"
    # Log the specific error to help with debugging
    Write-Log $_.Exception.Message -Level "ERROR"
}

Install-PipxTools


# 6. Final setup and verification
#    - Run health checks and provide next steps.
Write-Log "Step 6: Finalizing setup..."

if ($ScriptHasErrored) {
    Write-Host "`n"
    Write-Host "------------------------------------------------------------" -ForegroundColor Red
    Write-Host "❌ Automated Setup Failed." -ForegroundColor Red
    Write-Host "Errors were detected during the installation process." -ForegroundColor Yellow
    Write-Host "Please review the logs above to diagnose the issue." -ForegroundColor Yellow
    Write-Host "The script must complete without errors before proceeding." -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------" -ForegroundColor Red
    Write-Host "`n"
} else {
    Write-Log "✅ Windows dotfiles setup script completed." -Level "INFO"

    # --- Final Authentication Check ---
    $authScriptsToRun = @()
    # Check 1: Git Signing Key
    $gitConfigLocalPath = Join-Path $HOME ".gitconfig.local"
    $signingKey = ""
    if (Test-Path $gitConfigLocalPath) {
        $signingKey = Select-String -Path $gitConfigLocalPath -Pattern "signingkey" | Select-Object -First 1
    }
    if ([string]::IsNullOrWhiteSpace($signingKey) -or $signingKey -match "YOUR_SSH_PUBLIC_KEY_HERE") {
        $authScriptsToRun += ".\scripts\setup-ssh-signing.ps1  (To configure Git commit signing)"
    }

    # Check 2: GitHub CLI Auth
    gh auth status | Out-Null
    if ($LASTEXITCODE -ne 0) {
        $authScriptsToRun += ".\scripts\setup-github-cli.ps1   (To log in to the GitHub CLI)"
    }

    if ($authScriptsToRun.Count -gt 0) {
        Write-Host "`n"
        Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
        Write-Host "✅ Automated Setup Complete!" -ForegroundColor Green
        Write-Host "The final step is to configure your personal authentication." -ForegroundColor Yellow
        Write-Host "Please run the following interactive scripts:" -ForegroundColor Yellow
        foreach ($script in $authScriptsToRun) {
            Write-Host "  -> $script"
        }
        Write-Host "------------------------------------------------------------" -ForegroundColor Cyan
        Write-Host "`n"
    } else {
        Write-Host "`n"
        Write-Host "------------------------------------------------------------" -ForegroundColor Green
        Write-Host "🎉 System Fully Configured!" -ForegroundColor Green
        Write-Host "All tools are installed and authentication is set up." -ForegroundColor Green
        Write-Host "------------------------------------------------------------" -ForegroundColor Green
        Write-Host "`n"
    }
} 