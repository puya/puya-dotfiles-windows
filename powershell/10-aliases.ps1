<#
.SYNOPSIS
    PowerShell Aliases
.DESCRIPTION
    Defines a set of useful aliases for common commands and modern tools.
#>

# --- Modern Tool Replacements ---
# Note: These require the tools to be installed via Scoop.
if (Get-Command eza -ErrorAction SilentlyContinue) {
    Set-Alias -Name ls -Value eza -Option AllScope
    function Invoke-EzaTree { eza --tree }
    Set-Alias -Name tree -Value Invoke-EzaTree -Option AllScope
}

if (Get-Command bat -ErrorAction SilentlyContinue) {
    Set-Alias -Name cat -Value bat -Option AllScope
}

# --- Git Shortcuts ---
if (Get-Command git -ErrorAction SilentlyContinue) {
    function Invoke-GitStatus { git status }
    Set-Alias -Name gs -Value Invoke-GitStatus -Option AllScope

    function Invoke-GitAdd { git add $args }
    Set-Alias -Name ga -Value Invoke-GitAdd -Option AllScope

    function Invoke-GitCommit { git commit $args }
    Set-Alias -Name gc -Value Invoke-GitCommit -Option AllScope -Force

    function Invoke-GitPush { git push $args }
    Set-Alias -Name gp -Value Invoke-GitPush -Option AllScope -Force

    function Invoke-GitLog { git log --oneline --graph --decorate }
    Set-Alias -Name gl -Value Invoke-GitLog -Option AllScope -Force
}

# --- Development Shortcuts ---
function Invoke-HttpServer { python -m http.server 8000 }
Set-Alias -Name serve -Value Invoke-HttpServer -Option AllScope

function Get-MyIP {
    (Invoke-RestMethod -Uri "http://ipecho.net/plain").ToString()
}
Set-Alias -Name myip -Value Get-MyIP -Option AllScope

# --- Directory & File Operations ---
function New-DirectoryAndEnter {
    param([string]$Path)
    New-Item -ItemType Directory -Path $Path | Out-Null
    Set-Location -Path $Path
}
Set-Alias -Name mkcd -Value New-DirectoryAndEnter -Option AllScope

# --- Configuration Shortcuts ---
$DotfilesWindows = "$HOME\dotfiles\puya-dotfiles-windows"
function Open-DotfilesWindows { code $DotfilesWindows }
Set-Alias -Name dotfilesw -Value Open-DotfilesWindows -Option AllScope

function Open-PSProfile { code $PROFILE }
Set-Alias -Name psprofile -Value Open-PSProfile -Option AllScope 

# --- Navigation & Listing ---
# The PowerShell equivalent of 'which' is 'Get-Command'
Set-Alias -Name which -Value Get-Command -Option AllScope
Set-Alias -Name la -Value Get-ChildItem -Force -Option AllScope

# Special 'll' function to handle eza if present
function Invoke-LongList {
    if (Get-Command eza -ErrorAction SilentlyContinue) {
        eza -l -g --icons
    } else {
        Get-ChildItem -Option AllScope
    }
}
Set-Alias -Name ll -Value Invoke-LongList -Option AllScope


# --- System & Command Information ---
Set-Alias -Name psver -Value Get-PSVersionTable -Option AllScope 