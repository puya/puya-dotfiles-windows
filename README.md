# 🧰 Puya's Dotfiles for Windows

A personal collection of configuration files and automation scripts for setting up a complete development environment on **Windows**, powered by PowerShell. This setup uses **Scoop** for package management and **mise** for tool version management.

## ✨ What This Repo Provides

-   **🚀 One-Command Setup**: `.\init.ps1` installs and configures everything from system packages to your PowerShell profile.
-   **📦 Declarative Management**: `scoopfile.json` for system packages and `.tool-versions` for language runtimes.
-   **🎨 Gorgeous Terminal**: A customized prompt via Oh My Posh, with icons provided by an auto-installed Nerd Font.
-   **🐚 Modern Shell**: A modular PowerShell profile with useful aliases (`ls` → `eza`, `cat` → `bat`) and helper functions.
-   **💻 Works Everywhere**: The profile is robustly designed to work in both Windows Terminal and integrated terminals (VS Code, Cursor).
-   **🩺 Health Checks**: A `doctor.ps1` script to validate your environment and check for issues.

## 🚀 Setup Instructions

### 1. Initial Clone
On a new Windows machine, open PowerShell and run:

```powershell
# Set execution policy to allow local scripts to run for the current session
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# Clone the repository
git clone https://github.com/puyalk/puya-dotfiles.git $HOME\dotfiles
```

### 2. Run the Initialization Script
This is the main step that automates the entire setup.

```powershell
# Navigate to the dotfiles directory and run the setup
cd $HOME\dotfiles
.\init.ps1
```
The script handles everything: Scoop, packages, development tools, and your PowerShell profile.

### 3. **IMPORTANT**: Set Terminal Font
To see the icons in your prompt correctly, you must configure your terminal to use a Nerd Font. The setup script installs **`Cascadia-Code`**, which includes `CaskaydiaCove NF`.

-   **Windows Terminal**: `Settings` > `Profiles` > `PowerShell` > `Appearance` > Font face: **`CaskaydiaCove NF`**.
-   **VS Code/Cursor**: `Settings` > Search for `terminal font` > Font Family: **`CaskaydiaCove NF`**.
-   Restart your terminal after changing the font.

## 🗂️ Repository Structure

-   `init.ps1`: **Main setup script.**
-   `doctor.ps1`: Validates the environment setup.
-   `update-versions.ps1`: Helper script to update language versions in `.tool-versions`.
-   `scoopfile.json`: Declarative list of system packages managed by Scoop.
-   `.tool-versions`: Version-locked development tools for `mise`.
-   `powershell/`: Contains all modular PowerShell configuration files (`profile.ps1`, `01-environment.ps1`, `10-aliases.ps1`).
-   `gitconfig`: Universal Git settings (linked to `$HOME\.gitconfig`).

## 🔐 Security & Authentication

This environment is designed to use 1Password for securely managing SSH keys for Git and GitHub authentication.

-   **Git Commit Signing**: After setup, run `doctor.ps1` to check your Git signing status.
-   **GitHub CLI**: The `gh` tool will use keys from the 1Password agent for authentication.
-   **No Plaintext Secrets**: All sensitive data is managed through 1Password, never committed to the repository.

## 🆘 Troubleshooting

-   **Script failed?** The `init.ps1` script is designed to be resumable. Simply run it again.
-   **Missing icons in prompt?** Make sure you have set the font to `CaskaydiaCove NF` in your terminal's settings (Step 3 above).
-   **Missing commands?** Close and restart your terminal. If that doesn't work, run `doctor.ps1` to diagnose the issue. 