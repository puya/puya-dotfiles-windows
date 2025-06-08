# 🧰 Puya's Dev Setup Reference

## 🖥️ System Overview
- **OS:** macOS (Homebrew installed)
- **Terminal:** VSCode/Cursor integrated terminal
- **Shell:** `zsh` with **Oh My Zsh**
- **Package Manager:** `brew`

---

## 📦 Homebrew (Package Manager)
- Homebrew is the **macOS package manager** that installs software, libraries, CLI tools, and apps.
- It installs to `/usr/local` (or `/opt/homebrew` on M1/M2 Macs).
- Used to install tools like `asdf`, `git`, `wget`, `htop`, etc.

**Examples:**
```sh
brew install asdf
brew install wget
brew install poetry
```

---

## 🌀 Shell: `zsh` + Oh My Zsh (Modular Configuration)
- **Zsh** is your terminal shell (replaces Bash on modern macOS).
- **Oh My Zsh** is a community-driven framework for managing your Zsh config:
  - Adds themes
  - Adds plugins
  - Manages `.zshrc`

**Installed via:**
```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Modular Configuration Structure:
The shell configuration is now split into focused modules for better organization:

- **`zsh/exports.zsh`** - Environment variables, PATH modifications, and editor config
- **`zsh/aliases.zsh`** - Command shortcuts, Git aliases, and modern tool replacements
- **`zsh/functions.zsh`** - Useful shell functions (mkcd, extract, killport, etc.)
- **`zsh/asdf.zsh`** - ASDF version manager configuration and completions

### Main `.zshrc` Setup:
```sh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git asdf)
source $ZSH/oh-my-zsh.sh

# Automatically source all modular configuration files
DOTFILES_DIR="$(dirname "$(readlink ~/.zshrc 2>/dev/null || echo ~/.zshrc)")"
for config_file in "$DOTFILES_DIR/zsh"/*.zsh; do
  [[ -r "$config_file" ]] && source "$config_file"
done

# Source local overrides if they exist
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

### Poetry with ASDF:
```sh
asdf plugin add poetry
asdf install poetry latest # Or specific version from .tool-versions
```

### Examples of other tools to install with ASDF:
```sh
asdf plugin add deno
asdf install deno latest
asdf set -g deno latest

asdf plugin add java
asdf install java openjdk-17
asdf set -g java openjdk-17
```

Use `asdf list all <tool>` to see all available versions.

---

## 🧩 ASDF (Version Manager)
- **ASDF is a universal version manager** for programming languages and CLI tools.
- Manages multiple versions of:
  - Node.js
  - Python
  - Ruby
  - Java
  - Deno
  - Go
  - Rust
  - Terraform
  - ...and many more

**Why use ASDF over Homebrew for languages?**
✅ ASDF allows **version switching per project** (via `.tool-versions`)
✅ Isolates environments (e.g., different Node/Python versions for different projects)
✅ Works seamlessly with tools like Poetry, nvm, pyenv, etc.

### Installed via:
```sh
brew install asdf
```

### Required shell init:
Add this to your `~/.zshrc`:
```sh
. $(brew --prefix asdf)/libexec/asdf.sh
```

### Node.js with ASDF:
```sh
asdf plugin add nodejs
asdf install nodejs latest
asdf set -g nodejs 20.11.1
```

### Python with ASDF:
```sh
asdf plugin add python
asdf install python 3.13.3
asdf set -g python 3.13.3
```

### Examples of other tools to install with ASDF:
```sh
asdf plugin add deno
asdf install deno latest
asdf set -g deno latest

asdf plugin add java
asdf install java openjdk-17
asdf set -g java openjdk-17
```

Use `asdf list all <tool>` to see all available versions.

---

## 🐍 Python + Poetry
- Python and Poetry are now managed by `asdf` (not Homebrew)
- Poetry uses the active Python version from `asdf`:

```sh
poetry env use $(asdf which python)
```

This ensures Poetry uses the ASDF-managed Python version.

Each project has its own isolated environment.

ASDF will auto-switch to these versions when you `cd` into the folder.

Global versions are set via the `.tool-versions` file symlinked to `$HOME`.

---

## ⚡ `uv` (Ultra-Fast Python Tooling)

- **`uv` is an extremely fast Python package manager and tooling suite written in Rust.**

- It serves as a comprehensive replacement for multiple Python tools:
  - Package installation (`pip`)
  - Virtual environment management (`virtualenv`/`venv`)
  - Command-line tool installation (`pipx`)
  - Python version management (like `pyenv`)

- Its key advantages include:
  - 10-100x faster than traditional Python tools
  - Single binary with no Python dependencies
  - Automatic virtual environment management
  - Isolated tool installation (like `pipx`)
  - Python version management built-in

### Installed via ASDF (Recommended):

The `init.sh` script handles the installation and configuration of `uv` using `asdf`. Here's how it works:

1.  **Plugin Addition**:
    ```sh
    asdf plugin add uv
    ```
    This ensures the `uv` plugin is available to `asdf`.

2.  **Installation of Latest Version**:
    ```sh
    asdf install uv latest
    ```
    This command installs the most recent version of `uv` available through the `asdf` plugin.

3.  **Setting Global Version and Updating `.tool-versions`**:
    ```sh
    asdf set -g uv latest
    ```
    This command sets the just-installed latest version of `uv` as the global default. Crucially, it also **updates your global `~/.tool-versions` file** (which is symlinked from `~/dotfiles/.tool-versions`) to pin this specific latest version (e.g., `uv 0.7.5` or whatever version was fetched).

This approach ensures that your development environment is always set up with the newest stable release of `uv` during the initial setup, and that version is then recorded in `.tool-versions` for consistency. If you wish to use a different specific version of `uv` later, you can manually change it in `.tool-versions` and run `asdf install`.

# Alternative: Direct installation script (if not using ASDF for uv)
# curl -LsSf https://astral.sh/uv/install.sh | sh

### Key Use Cases for `uv`:

1. **Installing Global Python CLI Tools**:

   - Use `uv tool install <package_name>` to install tools globally but in isolated environments:
     ```sh
     uv tool install ruff
     uv tool install black
     ```

   - Or run tools without installing them permanently:
     ```sh
     uvx ruff check .  # (uvx is an alias for uv tool run)
     ```

2. **Fast Virtual Environment Management**:

   - Create: `uv venv`
   - Activate: `source .venv/bin/activate`

3. **Fast Package Installation**:

   - Install packages: `uv pip install <package_name>`
   - Install from requirements: `uv pip install -r requirements.txt`

4. **Python Version Management**:

   - Install Python versions: `uv python install 3.13`
   - Use a specific version for your project: `uv python pin 3.13`

## 🆚 When to Use `Poetry` vs. `uv`

While both tools can manage Python packages, they serve different primary purposes in this setup:

*   **Use `Poetry` for:**

    *   **Comprehensive Project Dependency Management**: When working *inside* a Python project that requires a fully featured dependency manager with lockfiles.
    
    *   **Reproducible Environments**: Defining and locking project dependencies for consistent builds across team members.
    
    *   **Managing Project-Specific Packages**: When you need fine-grained control over your project's dependencies.

*   **Use `uv` for:**

    *   **Installing Global Python CLI Tools**: For tools that you want to use system-wide or across multiple projects.
    
    *   **Quick, Isolated Environments**: When you need a fast, lightweight Python environment.
    
    *   **Python Version Management**: For projects that need specific Python versions.
    
    *   **Ultra-Fast Package Installation**: When speed is critical and you want to bypass the slower pip experience.

**Important Note**: Don't use `brew install uv` as it will compile from source and is extremely slow on older Macs. Always use ASDF or the standalone installer script.

---

## 📁 `.tool-versions` Example

This file (placed in any project directory) locks tools per project:

```txt
python 3.13.3
nodejs 20.11.1
deno 1.41.0
poetry 1.8.3 # Added poetry
```
ASDF will auto-switch to these versions when you `cd` into the folder.

---

## 📂 Dotfiles Repo + Dotbot Setup (Optional)

**Dotbot** is a tool to automate symlinking your dotfiles into place.
Great for setting up a new machine in one step.

### Basic Folder Structure:
```
dotfiles/
├── .zshrc
├── .tool-versions
├── dev-setup.md
├── install.conf.yaml
└── install  (a shell script that runs Dotbot)
```

### Minimal `install.conf.yaml`:
```yaml
- link:
    ~/.zshrc: .zshrc
    ~/.tool-versions: .tool-versions
    ~/dev-setup.md: dev-setup.md
```

### Dotbot Install Script:
```sh
#!/bin/bash
set -e
git submodule update --init --recursive
./dotbot/bin/dotbot -c install.conf.yaml
```

To use Dotbot, clone it into your dotfiles repo as a submodule:
```sh
git submodule add https://github.com/anishathalye/dotbot
```

Then run:
```sh
./install
```

---

## 🩺 Health Check System

The `doctor.sh` script provides comprehensive health checks for your development environment:

```sh
./doctor.sh
```

**What it checks:**
- ✅ **System Information** - Platform, shell, user details
- ✅ **Homebrew** - Installation, health, and Brewfile packages
- ✅ **Core Tools** - Git, GitHub CLI, ASDF, and essential utilities
- ✅ **Language Environments** - Python, Node.js, and version matching
- ✅ **Dotfiles** - Proper symlinking and modular configuration
- ✅ **Git & SSH** - Authentication, signing, and 1Password integration
- ✅ **Shell Configuration** - ZSH, Oh My Zsh, and ASDF loading

**Color-coded output:**
- 🟢 **Green**: Everything working correctly
- 🟡 **Yellow**: Warnings (optional features or minor issues)
- 🔴 **Red**: Critical issues that need attention

Run this regularly to ensure your environment stays healthy!

## 🧠 Tips
- Keep this file (`dev-setup.md`) in your `dotfiles` repo
- Use it to track versions, config, and setup decisions
- Expand your `dotfiles` repo with aliases, functions, and other config over time
- Document changes as you go to keep your setup reproducible and transparent
- Run `./doctor.sh` after making changes to validate your setup

---

💬 Feel free to extend this file with sections for:
- Git config
- VSCode settings
- Terminal themes
- Dev tools like Docker, PostgreSQL, Redis, etc.

Let this file be your north star when setting up a new machine 💫

## 🧩 Optional: Per-machine Git Signing Config

If you're using SSH commit signing (e.g. via 1Password), we recommend keeping your signing key in a separate untracked file.

1. Create a `~/.gitconfig.local` file (this is ignored by Git):

```ini
[user]
  signingkey = ssh-ed25519 AAAA...your-key
```

2. This file is automatically included by `.gitconfig`:

```ini
[include]
  path = ~/.gitconfig.local
```

💡 Do **not** include your full signing key in your public dotfiles — this allows per-machine control without exposing secrets.

---

## ✍️ IMPORTANT: Setting Up Git Commit Signing (Per Machine)

Your main `.gitconfig` (managed by these dotfiles) is set up to sign Git commits using an SSH key via 1Password. To make this work on each new machine, you **must** create a local configuration file (`~/.gitconfig.local`) that tells Git *which* of your SSH keys (managed by 1Password) to use for signing.

**Follow these steps carefully on each machine where you use these dotfiles:**

1.  **Ensure 1Password is Ready:**
    *   Install and sign into the 1Password desktop application.
    *   In 1Password's **Settings > Developer**, ensure **"Use the SSH Agent"** is enabled.
    *   If prompted by 1Password, allow it to configure your SSH settings (it might offer to modify `~/.ssh/config` to use its agent).
    *   Ensure the SSH key you want to use for signing is loaded and authorized in 1Password.

2.  **Ensure Shell is Configured for 1Password Agent:**
    *   Your `.zshrc` (managed by these dotfiles) now sets the `SSH_AUTH_SOCK` environment variable to point to the 1Password agent. This should happen automatically when you open a new terminal after the dotfiles are set up.

3.  **List Your Available SSH Keys:**
    *   Open a **new terminal window** (to ensure all shell configurations are loaded).
    *   Run the command: `ssh-add -L`
    *   This command will list the public SSH keys that the 1Password agent is currently providing. The output will look something like:
        ```
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHlourExampleKey... user@example.com
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC8LJh... Another Key Title
        ```

4.  **Identify Your Git Signing Key:**
    *   From the list provided by `ssh-add -L`, identify the **full public key string** (starting with `ssh-ed25519 AAAA...` or `ssh-rsa AAAA...` and including the comment/title at the end) that you want to use for signing your Git commits.
    *   **Tip**: Give your Git signing key a clear title in 1Password (e.g., "Git Commit Signing Key") to make it easy to recognize in the `ssh-add -L` output.

5.  **Create/Edit `~/.gitconfig.local`:**
    *   Create a new file (or edit if it exists for other reasons) at `~/.gitconfig.local` (i.e., in your home directory).
    *   Add the following content, **replacing the example key with the full public key string you identified in the previous step**:
        ```ini
        [user]
          signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHlourExampleKey... user@example.com
        ```
        *Make sure to copy the entire line from `ssh-add -L` for your chosen key as the value for `signingkey`.*

6.  **Verify (Optional but Recommended):**
    *   Try making a test commit in a local Git repository: `git commit --allow-empty -m "Test commit signing"`
    *   1Password should prompt you to authorize the signing operation (depending on your 1Password approval settings).
    *   Check the commit log with `git log --show-signature -1`. You should see information indicating the commit was signed with your key.

**Why this process?**

*   Your main `.gitconfig` enables signing and points to 1Password.
*   `~/.gitconfig.local` is specific to each machine and tells Git *which specific key* from your 1Password agent to use on *that particular machine*. This file is intentionally **not** part of your public dotfiles repository because the choice of key might differ between machines, or you might not have set it up yet.

By following these steps, your commits will be signed using the SSH key securely managed by 1Password.