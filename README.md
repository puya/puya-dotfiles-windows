# 🧰 Puya's Dotfiles

A personal collection of configuration files and setup tools for my development environment on macOS. Powered by [`dotbot`](https://github.com/anishathalye/dotbot) for easy setup.

## 🔧 What's included

- **ZSH** shell configuration with [Oh My Zsh](https://ohmyz.sh/) and modular configuration
- **ASDF** version manager for Node.js, Python, and more
- **Homebrew** package management with `Brewfile`
- `.tool-versions` to auto-switch runtime versions per project
- `dev-setup.md` with a full write-up of how my system is configured
- Dotbot for automatic symlinking of config files
- **Health check system** to validate your environment
- **Error recovery** and logging for robust setup

## 🚀 Quick setup (on a new machine)

```bash
git clone --recursive git@github.com:puya/puya-dotfiles.git ~/dotfiles
cd ~/dotfiles
./init.sh
```

This will install Homebrew (if missing), packages via Brewfile, asdf, oh-my-zsh, gh, all configured versions, link all your dotfiles using Dotbot, and automatically run a health check to validate everything is working.

## 🩺 Health Check

After setup (or anytime), run the health check to validate your environment:

```bash
./doctor.sh
```

This will check:
- ✅ All required tools are installed and working
- ✅ Dotfiles are properly symlinked
- ✅ Version managers are configured correctly
- ✅ Git and SSH authentication is set up
- ✅ Shell configuration is loaded properly

## 📦 Package Management

Packages are managed declaratively via `Brewfile`:

```bash
# Install all packages
brew bundle

# Update Brewfile with currently installed packages
brew bundle dump --force

# Check what's missing
brew bundle check
```

## 📁 Files linked to home directory

| Target           | Source          | Description |
|------------------|------------------|-------------|
| `~/.zshrc`        | `.zshrc`          | Main shell configuration |
| `~/.tool-versions`| `.tool-versions`  | ASDF version pinning |
| `~/.gitconfig`    | `.gitconfig`      | Git configuration |
| `~/Brewfile`      | `Brewfile`        | Homebrew packages |
| `~/zsh/`          | `zsh/`            | Modular shell configs |

## 🔧 Modular Shell Configuration

The shell configuration is split into focused modules:

- `zsh/exports.zsh` - Environment variables and PATH
- `zsh/aliases.zsh` - Command shortcuts and aliases  
- `zsh/functions.zsh` - Useful shell functions
- `zsh/asdf.zsh` - Version manager configuration

## 🛠️ Error Recovery

The setup script includes:
- **Logging**: All output is logged to `~/.dotfiles-setup.log`
- **Step tracking**: Resume from where you left off if setup fails
- **Platform detection**: Automatically handles Apple Silicon vs Intel Macs
- **Validation**: Checks prerequisites before proceeding

## 🧠 Notes

- This repo is a living setup. Expect updates and tweaks as I refine my workflow.
- Feel free to fork or use as a base for your own dotfiles!
- Run `./doctor.sh` regularly to ensure your environment stays healthy

*This setup is actively maintained and updated.*
