# 🛠️ Windows Development Environment Reference

Your complete guide to the tools, aliases, functions, and workflows available in this native Windows development environment.

## 🖥️ System Overview

-   **OS**: Windows with Scoop package management
-   **Shell**: PowerShell 7+
-   **Terminal**: Windows Terminal (or VS Code/Cursor) with a Nerd Font (`Cascadia Code NF`)
-   **Prompt**: Oh My Posh for a themed, Git-aware prompt
-   **Authentication**: 1Password SSH agent for secure, biometric authentication
-   **Version Management**: `mise` for consistent tool versions across projects

---

## 🚀 Essential Commands & Aliases

### Modern Tool Replacements
```powershell
ls          # → eza (modern ls with colors and icons)
ll          # → eza -l -g --icons (detailed list)
tree        # → eza --tree (directory tree view)
cat         # → bat (syntax-highlighted file viewer)
which       # → Get-Command (finds the path of a command)
```

### Git Shortcuts
```powershell
gs          # git status
ga          # git add
gc          # git commit
gp          # git push
gl          # git log --oneline --graph --decorate
```

### Development & Config Shortcuts
```powershell
serve       # python -m http.server 8000 (quick local server)
myip        # Shows your public IP address
dotfilesw   # Opens this dotfiles directory in VS Code/Cursor
psprofile   # Opens your PowerShell profile file in VS Code/Cursor
```

---

## 🔧 Useful Shell Functions

### Directory & File Operations
```powershell
mkcd <dirname>              # Create a new directory and navigate into it
```

---

## 📦 Package & Version Management

### `mise` - Polyglot Version Manager
`mise` automatically switches tool versions based on `.tool-versions` files. Your global versions are configured by `init.ps1`.

```powershell
mise current               # Show all active tool versions
mise use --global python@latest  # Set a new global version for a tool
mise use --local node@lts  # Set a project-specific version (creates .tool-versions)
mise install               # Install tools defined in the local .tool-versions
```

### Scoop - System Package Manager
Scoop installs and manages all your command-line tools. The list is defined in `scoopfile.json`.

```powershell
scoop list                 # List all installed packages
scoop update *             # Update all packages
scoop install <package>    # Install a new package
```

---

## 🔐 Authentication & Security

The environment is configured to use the 1Password SSH agent for Git and GitHub CLI authentication.

-   **Verify Setup**: Run `doctor.ps1` to check your Git signing status and key availability.
-   **Signing Commits**: `git commit` will automatically use your SSH key for signing. 1Password will prompt for approval.
-   **GitHub CLI**: The `gh` command is also authenticated via the 1Password agent.

---

## 🎯 Workflow Tips

### Quick Project Setup
```powershell
# Create a new project directory and enter it
mkcd my-new-app

# Initialize it as a Git repository and make first commit
git init
git commit --allow-empty -m "Initial commit"

# Set the local node version for this project
mise use --local node@lts

# Open in VS Code/Cursor
code .
```

### Keeping Everything Updated
```powershell
# 1. Update all Scoop packages (the tools themselves)
scoop update *

# 2. Update the language versions defined in this repository
.\update-versions.ps1
```

---

## 🔧 Customization

### Adding New Aliases or Functions
Edit the `powershell/10-aliases.ps1` file in this repository.

### Installing New Global Tools
1.  Add the tool's package name to `scoopfile.json`.
2.  Run `scoop install <package-name>` or re-run `.\init.ps1`.

### Installing New Language Versions Globally
Use `mise` to manage new versions of Python, Node, etc., and set them as the default.
```powershell
# Install the latest LTS version of Node.js and set it globally
mise use --global node@lts
``` 