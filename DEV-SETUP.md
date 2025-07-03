# 🛠️ Development Environment Reference

Your complete guide to the tools, aliases, functions, and workflows available in this development environment.

## 🖥️ System Overview

- **OS**: macOS with Homebrew package management
- **Shell**: Zsh with Oh My Zsh framework
- **Terminal**: Any terminal (optimized for VS Code/Cursor)
- **Authentication**: 1Password SSH agent for secure, biometric authentication
- **Version Management**: ASDF for consistent tool versions across projects

---

## 🚀 Essential Commands & Aliases

### Git Shortcuts
```bash
gs          # git status
ga          # git add
gc          # git commit
gp          # git push
gl          # git log --oneline --graph --decorate
```

### Configuration Shortcuts
```bash
dotfiles    # cd ~/dotfiles && code .
zshconfig   # code ~/.zshrc
ohmyzsh     # code ~/.oh-my-zsh
```

### Modern Tool Replacements
```bash
ls          # → eza (modern ls with colors and icons)
ll          # → eza -la (detailed list)
tree        # → eza --tree (directory tree view)
cat         # → bat (syntax-highlighted file viewer)
```

### Development Shortcuts
```bash
serve       # python -m http.server 8000 (quick local server)
myip        # curl http://ipecho.net/plain; echo (show public IP)
```

### Homebrew Management
```bash
brewup      # brew update && brew upgrade && brew cleanup
brewdump    # brew bundle dump --force --describe
```

---

## 🔧 Useful Shell Functions

### Directory & File Operations
```bash
mkcd <dirname>              # Create directory and cd into it
extract <archive>           # Universal archive extractor (supports zip, tar, gz, rar, 7z, etc.)
```

### Development Utilities
```bash
killport <port>             # Kill process running on specific port
dif <file1> <file2>         # Enhanced diff with diff-so-fancy (if available)
newproject <name>           # Quick project setup with git init and common files
```

### Examples
```bash
mkcd my-new-project         # Creates and enters directory
extract myfile.tar.gz       # Extracts any archive format
killport 3000              # Kills process on port 3000
newproject my-app          # Creates project with README, .gitignore, git init
```

---

## 🐍 Python Development

You have **both** Poetry and UV configured for different use cases:

### Poetry - Project Dependency Management
```bash
poetry new my-project       # Create new Python project
poetry add requests         # Add project dependency
poetry install             # Install project dependencies
poetry shell               # Activate project virtual environment
```

### UV - Fast Python Tooling
```bash
uv tool install ruff       # Install global Python CLI tools
uvx black .                # Run tools without installing (uv tool run)
uv venv                    # Create virtual environment (10-100x faster)
uv pip install requests    # Fast package installation
```

**When to use which:**
- **Poetry**: For Python projects with complex dependency management
- **UV**: For global tools, quick environments, and ultra-fast operations

---

## 🟨 JavaScript/TypeScript Development

Multiple JavaScript runtimes for different use cases:

### Node.js - Traditional Runtime
```bash
node app.js                # Run JavaScript file
npm install                # Install dependencies
npm run dev               # Run development script
npx create-react-app .    # Run packages without installing
```

### Deno - Modern Secure Runtime
```bash
deno run app.ts           # Run TypeScript directly (no compilation step)
deno run --allow-net app.ts  # Run with network permissions
deno test                 # Built-in test runner
deno fmt                  # Built-in formatter
deno lint                 # Built-in linter
deno install script.ts    # Install executable scripts
```

### Bun - Ultra-Fast Runtime
```bash
bun run app.ts            # Run TypeScript 3x faster than Node
bun install               # Install packages (much faster than npm)
bun test                  # Built-in fast test runner
bun build app.ts          # Built-in bundler
bunx create-react-app .   # Run packages without installing (faster than npx)
```

**When to use which:**
- **Node.js**: Existing projects, maximum ecosystem compatibility
- **Deno**: New projects prioritizing security and modern standards
- **Bun**: Performance-critical applications and faster development workflows

---

## 📦 Package & Version Management

### ASDF - Universal Version Manager
```bash
asdf list                  # Show installed versions
asdf current               # Show current versions for all tools
asdf install python latest # Install latest Python
asdf global python 3.13.5 # Set global Python version
```

### Homebrew - System Packages
```bash
brew install <package>     # Install new package
brew bundle               # Install all packages from Brewfile
brew bundle check         # Check which packages are missing
brew search <term>        # Search for packages
```

---

## 🔐 Authentication & Security

### 1Password SSH Agent
All SSH keys are stored securely in 1Password with biometric authentication:

```bash
ssh-add -L                 # List available SSH keys from 1Password
git commit -m "message"    # Automatically signed with 1Password SSH key
gh repo list              # GitHub CLI with biometric authentication
```

### GitHub CLI with 1Password
```bash
gh repo list              # List your repositories (with biometric auth)
gh issue list             # List issues
gh pr create              # Create pull request
op plugin inspect gh     # View 1Password plugin configuration
```

---

## 🛠️ Development Tools Installed

### Core Development
- **Git** - Version control with SSH signing
- **GitHub CLI** - GitHub operations with 1Password integration
- **ASDF** - Version manager for Python, Node.js, Poetry, UV
- **1Password CLI** - Secure credential management

### Modern CLI Tools
- **eza** - Modern `ls` replacement with colors and icons
- **bat** - Syntax-highlighted `cat` replacement
- **ripgrep** - Ultra-fast text search
- **fd** - Modern `find` replacement
- **diff-so-fancy** - Enhanced git diff output
- **jq** - JSON processor
- **htop** - Interactive process viewer

### Language Environments
- **Python 3.13.5** - Latest stable Python
- **Node.js LTS** - Latest Long Term Support version
- **Deno 2.4.0** - Modern TypeScript-first runtime
- **Bun 1.2.17** - Ultra-fast JavaScript runtime & toolkit
- **Poetry 2.1.3** - Python dependency management
- **UV 0.7.15** - Ultra-fast Python tooling

---

## 🎯 Workflow Tips

### Quick Project Setup
```bash
newproject my-app          # Creates directory, git init, README, .gitignore
cd my-app
poetry init               # Set up Python project (if needed)
code .                    # Open in VS Code/Cursor
```

### Environment Health Check
```bash
./doctor.sh               # Comprehensive environment validation
asdf current              # Check tool versions
brew bundle check        # Check missing packages
```

### Keeping Everything Updated
```bash
./update-versions.sh      # Update tool versions in .tool-versions
asdf install             # Install updated versions
brewup                   # Update Homebrew packages
```

### Archive Extraction Examples
```bash
extract file.zip         # Extracts ZIP
extract archive.tar.gz   # Extracts compressed tar
extract document.rar     # Extracts RAR
extract data.7z          # Extracts 7zip
```

---

## 🔧 Customization

### Adding New Aliases
Edit `~/dotfiles/zsh/10-aliases.zsh` and add:
```bash
alias myalias="my command"
```

### Adding New Functions
Edit `~/dotfiles/zsh/11-functions.zsh` and add:
```bash
myfunction() {
  echo "Your function here"
}
```

### Adding Device-Specific Tools
Edit `~/dotfiles/zsh/05-optional-paths.zsh`:
```bash
[[ -d "/path/to/tool" ]] && export PATH="/path/to/tool:$PATH"
```

### Local Overrides
Create `~/.zshrc.local` for machine-specific configurations that won't be synced.

---

## 🐙 Git Configuration

### Pre-configured Aliases (in ~/.gitconfig.local)
```bash
git co         # checkout
git br         # branch  
git ci         # commit
git st         # status
git lg         # log --oneline --graph --decorate --all
git unstage    # reset HEAD --
git last       # log -1 HEAD
git amend      # commit --amend --no-edit
git undo       # reset --soft HEAD~1
```

### SSH Signing with 1Password
- All commits automatically signed with SSH key from 1Password
- Biometric authentication for each signing operation
- No plaintext keys stored on disk

---

## 🚨 Troubleshooting

### Common Issues
```bash
# Tool not found after installation
asdf reshim <tool>         # Refresh ASDF shims

# Environment seems broken  
./doctor.sh               # Run full diagnostic

# Missing packages
brew bundle               # Install missing Homebrew packages
asdf install             # Install missing ASDF tools

# Authentication not working
op account list           # Check 1Password CLI status
ssh-add -L               # List available SSH keys
```

### Health Check Areas
- ✅ **System Info** - Platform, shell, user details
- ✅ **Homebrew** - Installation, packages, health
- ✅ **Core Tools** - Git, GitHub CLI, ASDF, 1Password CLI
- ✅ **Languages** - Python, Node.js versions
- ✅ **Dotfiles** - Symlink integrity
- ✅ **Authentication** - Git signing, SSH keys, GitHub CLI

---

This environment is designed for maximum productivity with security built-in. The modular shell configuration makes it easy to customize while maintaining a robust foundation.

**Need to modify something?** All configuration files are in your `~/dotfiles` directory and can be edited safely.