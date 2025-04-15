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

## 🌀 Shell: `zsh` + Oh My Zsh
- **Zsh** is your terminal shell (replaces Bash on modern macOS).
- **Oh My Zsh** is a community-driven framework for managing your Zsh config:
  - Adds themes
  - Adds plugins
  - Manages `.zshrc`

**Installed via:**
```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### `.zshrc` Active Setup:
```sh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh
. $(brew --prefix asdf)/libexec/asdf.sh
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
asdf set deno latest

asdf plugin add java
asdf install java openjdk-17
asdf set java openjdk-17
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
asdf set nodejs 20.11.1
```

### Python with ASDF:
```sh
asdf plugin add python
asdf install python 3.13.3
asdf set python 3.13.3
```

### Examples of other tools to install with ASDF:
```sh
asdf plugin add deno
asdf install deno latest
asdf set deno latest

asdf plugin add java
asdf install java openjdk-17
asdf set java openjdk-17
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

## 🧠 Tips
- Keep this file (`dev-setup.md`) in your `dotfiles` repo
- Use it to track versions, config, and setup decisions
- Expand your `dotfiles` repo with aliases, functions, and other config over time
- Document changes as you go to keep your setup reproducible and transparent

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