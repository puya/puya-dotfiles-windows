<#
.SYNOPSIS
    Environment Configuration
.DESCRIPTION
    Sets up environment variables, including robust PATH configuration.
#>

# --- Robust PATH Configuration ---
# Ensure Scoop executables are available. This is crucial for integrated terminals
# like in VS Code/Cursor which may not inherit the user PATH correctly.
$ScoopShimPath = "$env:USERPROFILE\scoop\shims"
if (-not ($env:PATH -like "*$ScoopShimPath*")) {
    $env:PATH = "$ScoopShimPath;$env:PATH"
}

# --- Environment Variables ---
$env:EDITOR = "code --wait"
$env:GIT_SSH = "C:/WINDOWS/System32/OpenSSH/ssh.exe"

# --- Status Message ---
if ($Host.Name -eq 'ConsoleHost') {
    Write-Host "🔧 Custom environment loaded." -ForegroundColor Cyan
} 