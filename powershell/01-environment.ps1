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

# --- Status Message ---
Write-Host "🔧 Custom environment loaded." -ForegroundColor Cyan 