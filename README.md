# 🧰 Puya's Dotfiles

A personal collection of configuration files and automation scripts for setting up a complete development environment on macOS. Powered by [Dotbot](https://github.com/anishathalye/dotbot) with robust setup automation and health monitoring.

## ✨ What This Repo Provides

- **🚀 One-Command Setup**: `./init.sh` installs everything from Homebrew to development tools
- **📦 Declarative Package Management**: `Brewfile` defines all your system packages
- **🔧 Version-Controlled Environment**: `.tool-versions` locks Python, Node.js, and other tool versions
- **🔐 Secure Authentication**: Integrated 1Password SSH agent for Git signing and GitHub CLI
- **🩺 Self-Healing**: `./doctor.sh` validates your environment and diagnoses issues
- **⬆️ Stay Current**: `./update-versions.sh` keeps tools at their latest stable releases
- **🐚 Modular Shell Config**: Clean, ordered zsh configuration with useful aliases and functions

## 🚀 Quick Setup

Clone and run on any new Mac:

```bash
git clone --recursive git@github.com:puya/puya-dotfiles.git ~/dotfiles
cd ~/dotfiles && ./init.sh
```

**That's it!** The script handles everything: Homebrew, packages, development tools, SSH keys, and shell configuration.

> 💡 **First time?** Definitely read through [`DEV-SETUP.md`](DEV-SETUP.md) to understand all the tools, aliases, and functions available in your new environment!

## 🗂️ Repository Structure

### 📝 Configuration Files
- `.zshrc` - Main shell configuration (auto-sources modular configs)
- `.gitconfig` - Git settings with 1Password SSH signing
- `.tool-versions` - Version-locked development tools (Python, Node.js, etc.)
- `Brewfile` - Declarative package management for Homebrew

### 🔧 Setup Scripts
- `init.sh` - **Main setup script** - installs and configures everything
- `setup-github-cli.sh` - Configure GitHub CLI with 1Password authentication
- `setup-ssh-signing.sh` - Interactive SSH signing setup helper
- `doctor.sh` - Environment health checker and diagnostics
- `update-versions.sh` - Update tool versions to latest stable releases

### 🐚 Modular Shell Configuration (`zsh/`)
- `01-exports.zsh` - Environment variables and PATH setup
- `02-asdf.zsh` - ASDF version manager initialization  
- `03-uv.zsh` - UV Python tooling configuration
- `05-optional-paths.zsh` - Device-specific tool paths (like john-jumbo)
- `10-aliases.zsh` - Command shortcuts and modern tool replacements
- `11-functions.zsh` - Useful shell functions

### 📋 Templates & Examples
- `templates/gitconfig.local.example` - Git local configuration template
- `install.conf.yaml` - Dotbot linking configuration

## 🛠️ Key Scripts Explained

### `./init.sh` - Complete Environment Setup
- Installs Homebrew and all packages from `Brewfile`
- Sets up ASDF and installs all tools from `.tool-versions`  
- Links dotfiles using Dotbot
- Configures 1Password SSH agent for Git signing
- Sets up GitHub CLI with biometric authentication
- Installs Oh My Zsh with modular configuration
- Runs health check to verify everything works

### `./doctor.sh` - Environment Health Check
Run anytime to validate your setup:
- ✅ System information and shell configuration
- ✅ Homebrew packages and health
- ✅ Development tools (Git, GitHub CLI, ASDF)
- ✅ Language environments (Python, Node.js)
- ✅ Dotfiles linking and SSH authentication

### `./update-versions.sh` - Keep Tools Current
- Checks for latest stable versions of tools in `.tool-versions`
- Smart handling: Node.js LTS, Python stable (no experimental builds)
- Updates file automatically - run `asdf install` to apply changes

## 🔐 Security Features

- **1Password SSH Agent**: All SSH keys stored securely in 1Password with biometric authentication
- **Git Commit Signing**: Automatic SSH-based commit signing via 1Password
- **GitHub CLI Integration**: Biometric authentication for GitHub operations
- **No Plaintext Secrets**: All sensitive data managed through 1Password

## 📦 What Gets Installed

**Core Development Environment:**
- **Package Manager**: Homebrew with declarative `Brewfile`
- **Version Manager**: ASDF for Python, Node.js, Poetry, UV
- **Python Stack**: Both Poetry (project management) and UV (fast tooling)
- **Modern CLI Tools**: `eza`, `bat`, `ripgrep`, `fd`, `diff-so-fancy`
- **Authentication**: 1Password CLI and SSH agent integration

**Shell Enhancement:**
- **Oh My Zsh**: Framework with Git and ASDF plugins
- **Modular Config**: Organized, numbered modules for clean loading order
- **Useful Aliases**: Git shortcuts, modern tool replacements, development helpers
- **Shell Functions**: `mkcd`, `extract`, `killport`, `newproject`, and more

> 📖 **See [`DEV-SETUP.md`](DEV-SETUP.md) for complete tool documentation, aliases reference, and development workflow tips!**

## 🔄 Maintenance Commands

```bash
# Check environment health
./doctor.sh

# Update tool versions to latest
./update-versions.sh && asdf install

# Update Homebrew packages  
brew bundle               # Install missing packages
brewup                    # Update all packages (alias)
brew bundle dump --force  # Regenerate Brewfile from installed packages

# Reconfigure authentication
./setup-github-cli.sh     # GitHub CLI setup
./setup-ssh-signing.sh    # SSH signing setup
```

## 🆘 Troubleshooting

**Setup failed?** The scripts are resumable:
- Check `~/.dotfiles-setup.log` for detailed error logs
- Simply run `./init.sh` again - it picks up where it left off
- Use `./doctor.sh` to identify specific issues

**Missing tools?** 
- Run `brew bundle` to install missing Homebrew packages
- Run `asdf install` to install missing development tools

**Authentication issues?**
- Ensure 1Password desktop app is running and SSH agent is enabled
- Use setup scripts: `./setup-ssh-signing.sh` or `./setup-github-cli.sh`

---

### 🚧 Future Enhancements Under Consideration
**Modern ZSH Framework Alternatives:**
- **[ZAP](https://github.com/zap-zsh/zap)**: Minimal, fast ZSH plugin manager as 
alternative to Oh My Zsh
- **[ZAP Supercharge](https://github.com/zap-zsh/supercharge)**: Enhanced ZSH experience 
with auto-CD, interactive completions, and quality-of-life improvements
- **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)**: Ultra-fast, 
feature-rich ZSH theme (framework-agnostic, works with current setup)
- **Performance**: ZAP offers 3-5x faster startup times compared to Oh My Zsh while 
maintaining compatibility with OMZ plugins

---

This dotfiles repository is actively maintained and battle-tested across multiple development environments. The modular approach makes it easy to customize while keeping the core functionality robust.

**Ready to explore your new environment?** → Read [`DEV-SETUP.md`](DEV-SETUP.md)
