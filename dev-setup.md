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

## ⚡ `uv` (Ultra-Fast Python Tooling)

- **`uv` is an extremely fast Python package installer and virtual environment manager.**

- Think of it as a high-performance replacement for many functionalities of `pip`, `venv`, and even `pipx`.

- It's particularly useful for:

  - Rapidly installing Python CLI tools into isolated environments (e.g., MCP servers, linters).

  - Quickly creating virtual environments.

  - Speeding up `pip install` operations in contexts where Poetry isn't used.


### Installed via:

`uv` is installed via Homebrew as part of the `init.sh` script:

```sh
brew install uv
```

This makes the `uv` command globally available.


### Key Use Cases for `uv`:

1.  **Installing Global Python CLI Tools**:

    - Use `uv tool install <package_name_or_git_url>` (e.g., `uv tool install ruff`, `uv tool install some-mcp-server`).

    - This installs the tool and its dependencies into an isolated environment and makes the executable available on your `PATH`.

    - Ideal for tools you want to use across different projects without them interfering with project-specific dependencies.


2.  **Fast Virtual Environment Management (outside Poetry projects)**:

    - Create: `uv venv`

    - Activate: `source .venv/bin/activate` (similar to standard venvs)


3.  **Fast Package Installation (outside Poetry projects or for global tools)**:

    - `uv pip install <package_name>`


---


## 🆚 When to Use `Poetry` vs. `uv`


While both tools can manage Python packages, they serve different primary purposes in this setup:


*   **Use `Poetry` for:**

    *   **Comprehensive Project Dependency Management**: When working *inside* a Python project (application or library) that has a `pyproject.toml` file.

    *   **Reproducible Environments**: Defining and locking project dependencies (`poetry.lock`) for consistent builds.

    *   **Managing Project-Specific Virtual Environments**: `poetry install` sets up the isolated environment for your project.

    *   **Running Project Tasks**: `poetry run <command>`.

    *   **Building and Publishing Packages**: `poetry build`, `poetry publish`.

    *   **Primary commands**: `poetry add`, `poetry install`, `poetry update`, `poetry run`.



*   **Use `uv` for:**

    *   **Installing Standalone/Global Python CLI Tools**: For tools you want to use system-wide or across multiple projects *without* adding them to each project's `pyproject.toml`.

        *   **Example**: `uv tool install ruff` (to have Ruff linter globally), `uv tool install an-mcp-server`.

        *   These tools are installed in isolated environments managed by `uv`, separate from your Poetry project environments.

    *   **Ad-hoc/Temporary Virtual Environments**: If you need a quick, temporary Python environment for a script or experiment *not* managed by Poetry.

        *   **Example**: `uv venv` followed by `source .venv/bin/activate` and then `uv pip install some_package`.

    *   **Speeding up one-off `pip install` tasks** where Poetry's full project management isn't needed.



**Key Distinction:**

-   **Poetry** is your *project-centric* manager. It handles the lifecycle and dependencies of a specific Python package or application you are developing.

-   **`uv`** (in this setup, primarily `uv tool install`) is for installing and managing *external Python tools* that you use *across* projects, or for very fast, lightweight environment/package operations *outside* the context of a Poetry-managed project.



**Do NOT use `uv pip install` to manage dependencies *inside* a Poetry project's activated environment, as this will bypass Poetry's dependency resolution and `poetry.lock` file, leading to inconsistencies. Always use `poetry add` for that.**


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