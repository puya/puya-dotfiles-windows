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
To see the icons in your prompt correctly, you must configure your terminals to use a Nerd Font. The setup script installs **`Cascadia-Code`**, which provides the **`Cascadia Code NF`** font face.

**For Windows Terminal:**
1.  Open Windows Terminal and go to `Settings` (you can use the dropdown or press `Ctrl + ,`).
2.  Select the **PowerShell** profile from the list on the left.
3.  Go to the **Appearance** tab.
4.  Under the **Font face** dropdown, select **`Cascadia Code NF`**.
5.  Click **Save**.

**For VS Code / Cursor:**
1.  Open VS Code or Cursor and go to `Settings` (you can use `File > Preferences > Settings` or press `Ctrl + ,`).
2.  In the search bar, type `terminal.integrated.fontFamily`.
3.  In the text box, enter **`Cascadia Code NF`**.
4.  Restart the terminal instance or the application for the change to take full effect.

### 4. Configure VS Code/Cursor Settings (Recommended)
For the best experience, add these essential settings to your `settings.json` file:

1.  Press `Ctrl+Shift+P` and type `Preferences: Open User Settings (JSON)`
2.  Add these key configurations:

```json
{
    "terminal.integrated.fontFamily": "Cascadia Code NF",
    "git.path": "C:\\Users\\YOUR_USERNAME\\scoop\\shims\\git.exe",
    "terminal.integrated.profiles.windows": {
        "PowerShell 7": {
            "source": "PowerShell",
            "path": "C:\\Program Files\\PowerShell\\7\\pwsh.exe",
            "icon": "terminal-powershell"
        }
    },
    "terminal.integrated.defaultProfile.windows": "PowerShell 7"
}
```

**Note**: Replace `YOUR_USERNAME` with your actual Windows username in the `git.path` setting.

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
-   **Missing icons in prompt?** Make sure you have set the font to `Cascadia Code NF` in your terminal's settings (Step 3 above).
-   **Missing commands?** Close and restart your terminal. If that doesn't work, run `doctor.ps1` to diagnose the issue. 
-   **PowerShell Extension crashing in VS Code/Cursor?** This can happen if your profile tries to run interactive commands. The profile is designed to prevent this, but if you've added custom commands, ensure they are wrapped in `if ($Host.Name -eq 'ConsoleHost') { ... }`. 

## 🔧 Maintenance

### Updating PowerShell and Other Core Tools

Since core tools like PowerShell and Git were installed manually via `winget`, you should use `winget` to update them.

```powershell
# To update PowerShell
winget upgrade Microsoft.PowerShell

# To update Git
winget upgrade Git.Git
```

### Updating Scoop-Managed Apps

For all the applications installed by the `init.ps1` script (via `scoopfile.json`), you can update them all at once using Scoop's built-in update command:

```powershell
scoop update *
```

This will check for new versions of all your tools like `mise`, `gh`, `nvm`, etc., and install them. 