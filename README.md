# 🧰 Puya's Dotfiles

A personal collection of configuration files and setup tools for my development environment on macOS, powered by [`dotbot`](https://github.com/anishathalye/dotbot) and a robust setup script.

## ✨ Features

- **Fully Automated Setup**: A single `./init.sh` script installs Homebrew, all packages, and necessary tools.
- **Declarative & Versioned**: `Brewfile` and `.tool-versions` define the entire environment.
- **Robust & Resumable**: Setup includes step-tracking, logging, and can be re-run to fix issues.
- **Self-Healing**: A `./doctor.sh` script validates the environment and helps diagnose problems.
- **Always Up-to-Date**: A `./update-versions.sh` script keeps tools at their latest stable releases.
- **Modular Shell**: Zsh configuration is split into clean, ordered, and extensible modules.

## 🚀 Quick Setup

The `init.sh` script will guide you through the entire setup. On a new machine, it only takes two commands:

```bash
git clone --recursive git@github.com:puya/puya-dotfiles.git ~/dotfiles
cd ~/dotfiles && ./init.sh
```

The script is idempotent, meaning you can safely run `./init.sh` again at any time to install missing tools or fix issues.

## ⚡ Simple Setup Flow

This is what the `init.sh` script automates for you:

1.  **🚀 Run Setup**: The script installs Homebrew, all packages from the `Brewfile`, and all `asdf` tool plugins.
2.  **⏸️ Pause & Edit**: The script pauses and opens `~/.gitconfig.local` in your editor.
3.  **🔑 Get SSH Key**: During the pause, you can run `ssh-add -L` in another terminal to get your SSH public key.
4.  **✅ You're Done**: Paste your key into the editor, save the file, and close it. The script finishes the setup. Restart your terminal to enjoy the new environment!

## 🛠️ Core Scripts

Your environment is managed by three key scripts:

-   `./init.sh`: **Installs and configures everything.** This is the main script to run on a new machine or to repair your existing setup.
-   `./doctor.sh`: **Checks environment health.** Run this anytime to validate that all tools, paths, and symlinks are correctly configured.
-   `./update-versions.sh`: **Updates tool versions.** This script checks for the latest stable releases of the tools in `.tool-versions` and updates the file for you. Run `asdf install` afterwards to apply the changes.

## 🐚 Modular Shell Configuration

The Zsh configuration is split into modules loaded in a specific order to ensure dependencies are met (e.g., environment variables are set before other scripts use them).

-   `zsh/01-exports.zsh`: Environment variables, `PATH` setup, and 1Password agent.
-   `zsh/02-asdf.zsh`: ASDF version manager initialization.
-   `zsh/10-aliases.zsh`: Command shortcuts and modern aliases (e.g., `ls` -> `eza`).
-   `zsh/11-functions.zsh`: Useful shell functions.

The numbering scheme leaves room for future expansion. Critical setup files are numbered `01-09`, while user-facing configs are `10-19`.

## 📦 Package Management

Your system packages are managed declaratively via the `Brewfile`. Here are some useful commands:

-   `brew bundle`: Installs all packages listed in the `Brewfile`. The `init.sh` script runs this automatically.
-   `brew bundle dump --force`: Overwrites your `Brewfile` with a list of all currently installed packages.
-   `brew bundle check`: Shows which packages from your `Brewfile` are missing.

## 🔐 Git & SSH Signing

The `init.sh` script handles the interactive setup of your SSH signing key. However, if you need to troubleshoot or re-configure it, the `./setup-ssh-signing.sh` script can guide you by checking your 1Password agent and listing available keys.

Your main `.gitconfig` is set up to include a machine-specific `~/.gitconfig.local` file. This is where your signing key and other local settings are stored, keeping them separate from your public dotfiles.

## 🩺 Health Check

After setup or anytime you suspect an issue, run the health check script:

```bash
./doctor.sh
```

This will validate your entire environment, including:
-   All required tools are installed and working.
-   Dotfiles are properly symlinked.
-   Version managers are configured correctly.
-   Git and SSH authentication is set up.

## 🛠️ Error Recovery

The setup script is built to be robust and includes:

-   **Logging**: All output is logged to `~/.dotfiles-setup.log` for easy debugging.
-   **Step Tracking**: If the setup fails, it saves the last step. You can simply re-run the script to resume from where you left off.
-   **Platform Detection**: Automatically handles differences between Apple Silicon and Intel Macs.

---

*This setup is actively maintained and updated.*
