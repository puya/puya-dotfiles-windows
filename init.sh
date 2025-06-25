#!/bin/bash
set -e

# -------------------------------
# 🔧 PLATFORM DETECTION & SETUP
# -------------------------------

# Detect platform
PLATFORM="unknown"
ARCH="$(uname -m)"
if [[ "$OSTYPE" == "darwin"* ]]; then
  PLATFORM="macos"
  if [[ "$ARCH" == "arm64" ]]; then
    HOMEBREW_PREFIX="/opt/homebrew"
  else
    HOMEBREW_PREFIX="/usr/local"
  fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  PLATFORM="linux"
  HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
fi

echo "🔍 Detected platform: $PLATFORM ($ARCH)"

# -------------------------------
# 📝 LOGGING & ERROR RECOVERY
# -------------------------------

LOG_FILE="$HOME/.dotfiles-setup.log"
STEP_FILE="$HOME/.dotfiles-step"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

save_step() {
  echo "$1" > "$STEP_FILE"
}

get_last_step() {
  if [[ -f "$STEP_FILE" ]]; then
    cat "$STEP_FILE"
  else
    echo "start"
  fi
}

cleanup_on_error() {
  log "❌ Setup failed at step: $(get_last_step)"
  log "📋 Check the log file: $LOG_FILE"
  log "🔄 You can resume by running this script again"
  exit 1
}

trap cleanup_on_error ERR

# -------------------------------
# 🚀 MAIN SETUP PROCESS
# -------------------------------

log "🛠️  Starting system setup..."
save_step "init"

# Install Homebrew if not already installed
# Check for the executable directly to be robust
if [ -x "$HOMEBREW_PREFIX/bin/brew" ]; then
    log "🍺 Homebrew already installed."
else
    log "🍺 Homebrew not found. Installing..."
    save_step "homebrew_install"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to this script's PATH
eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
log "✅ Homebrew is on the PATH for this script."

# Ask about updating Homebrew.
read -r -p "🤔 Do you want to update Homebrew and its packages (takes a few minutes)? (y/N): " update_brew_confirmation

# Always run brew bundle, but add `brew update` if confirmed.
if [[ "${update_brew_confirmation}" =~ ^[Yy]$ ]]; then
    log "🍺 Updating Homebrew..."
    save_step "homebrew_update"
    brew update
fi

log "🍺 Installing/upgrading packages with Homebrew Bundle..."
save_step "homebrew_packages"
if [[ -f "$HOME/.Brewfile" ]]; then
    # Using --no-lock prevents issues if a Brewfile.lock exists and is out of date.
    # We want to install based on the Brewfile definitions.
    brew bundle --file="$HOME/.Brewfile"
    log "✅ Homebrew packages installed/updated via Brewfile"
else
    log "⚠️  No Brewfile found, installing core packages individually..."
  brew install git gh asdf curl git-lfs
fi

# --- Critical Git Authentication Setup for Private Repositories ---
log "🤔 Checking existing Git configuration..."
save_step "git_config"

GITCONFIG_SYMLINK_TARGET="$(pwd)/.gitconfig"

if [ -L ~/.gitconfig ] && [ "$(readlink ~/.gitconfig)" = "$GITCONFIG_SYMLINK_TARGET" ]; then
  log "✅ ~/.gitconfig is already correctly symlinked to your dotfiles."
  log "   Assuming 1Password SSH authentication via ~/.gitconfig.local is configured."
  log "   Skipping manual SSH key setup steps."
else
  log "🔒 Git configuration needs attention for private repository access..."
  # Check if .gitconfig exists in the dotfiles directory
  if [ ! -f ".gitconfig" ]; then
    log "❌ ERROR: Your .gitconfig file is missing from the dotfiles directory."
    log "   This file is crucial for setting up Git user identity and 1Password SSH signing."
    log "   Please ensure .gitconfig is present in your dotfiles repository and run the script again."
    exit 1
  fi

  log "   Temporarily symlinking your .gitconfig to ~/.gitconfig..."
  # Remove existing ~/.gitconfig if it's a symlink or regular file to avoid ln error
  if [ -L ~/.gitconfig ] || [ -e ~/.gitconfig ]; then
    rm -f ~/.gitconfig
  fi
  ln -s "$GITCONFIG_SYMLINK_TARGET" ~/.gitconfig
  log "   ✅ Your .gitconfig has been temporarily linked."
  log "⏭️  SSH signing setup will be done after dotfiles are linked..."
fi
# --- Git Authentication Setup Done ---

log "📦 Setting up ASDF..."
save_step "asdf_setup"

# Temporarily source asdf for this script session FIRST
. "$(brew --prefix asdf)/libexec/asdf.sh" || log "Failed to source ASDF for init script, continuing..."
log "✅ ASDF environment sourced for this script."

log "🔌 Installing ASDF plugins from .tool-versions..."
save_step "asdf_plugins"
if [[ -f ".tool-versions" ]]; then
  # Use cut to get the first column (tool name) and iterate
  # This is more robust against lines with comments or different version formats
  cut -d' ' -f1 < .tool-versions | while read -r tool; do
    # Skip comments and empty lines
    [[ "$tool" == "#"* ]] || [[ -z "$tool" ]] && continue
    if ! asdf plugin list | grep -q "^${tool}$"; then
      log "   -> Adding plugin for $tool..."
      asdf plugin add "$tool"
    else
      log "   -> Plugin for $tool already exists."
    fi
  done
  log "✅ ASDF plugins are up to date."
else
    log "⚠️  .tool-versions not found, cannot install plugins."
fi

log "⬆️  Updating ASDF plugins to latest versions..."
save_step "asdf_plugin_update"
asdf plugin update --all || log "⚠️  ASDF plugin update finished (check output for errors)."

log "🔄 Updating tool versions to latest..."
save_step "asdf_version_update"
./update-versions.sh

log "📦 Installing Python first for dependencies..."
save_step "asdf_install_python"
asdf install python || log "⚠️  ASDF could not install python (check output for errors)."

log "🔄 Reshimming to make python available to other tools..."
asdf reshim python

log "📦 Installing other tools with ASDF..."
save_step "asdf_install_others"
# Install other tools; they can run in parallel now
asdf install || log "⚠️  ASDF install command finished (check output for errors)."

# Run dotfiles linking script FIRST (before SSH setup)
log "🔗 Linking dotfiles with Dotbot..."
save_step "dotbot_linking"
./link-dotfiles.sh # Use the renamed script

# Source the new shell configuration to get 1Password SSH agent
log "🔄 Loading new shell configuration for SSH setup..."
if [[ -f ~/.zshrc ]]; then
  # Source the modular configs directly since we can't reload the full zshrc in bash
  if [[ -f ~/.zsh/01-exports.zsh ]]; then
    source ~/.zsh/01-exports.zsh
    log "✅ 1Password SSH agent configuration loaded"
  fi
fi

# Set up .gitconfig.local with good defaults
if [[ -f "$HOME/.gitconfig.local" ]]; then
  log "✅ ~/.gitconfig.local already exists - skipping creation"
else
  if [[ -f "templates/gitconfig.local.example" ]]; then
    cp "templates/gitconfig.local.example" "$HOME/.gitconfig.local"
    log "📋 Created ~/.gitconfig.local with good defaults"
    log "🔑 You'll need to add your SSH signing key to this file"
  else
    log "⚠️  Template file not found - skipping .gitconfig.local creation"
  fi
fi

# Always copy the example file for reference
if [[ -f "templates/gitconfig.local.example" ]] && [[ ! -f "$HOME/.gitconfig.local.example" ]]; then
  cp "templates/gitconfig.local.example" "$HOME/.gitconfig.local.example"
  log "📋 Reference template copied to ~/.gitconfig.local.example"
fi

# Now set up SSH signing with proper environment
log "🔐 Setting up SSH signing with 1Password..."
save_step "ssh_signing_setup"
# Check if a non-commented 'signingkey' line contains the placeholder
if grep -q -E "^\s*signingkey\s*=\s*YOUR_SSH_PUBLIC_KEY_HERE" "$HOME/.gitconfig.local"; then
  log "Your Git configuration is ready, but you need to add your SSH signing key."
  log ""
  log "1. In another terminal, run: ssh-add -L"
  log "2. Copy one of your SSH public key strings (the full line)."
  log "3. You will be prompted to paste it in the editor that opens next."
  log ""
  read -r -p "✅ Press [Enter] when you are ready to edit ~/.gitconfig.local..."
  
  # Open the file in the user's editor
  ${EDITOR:-vim} "$HOME/.gitconfig.local"

  # Verify the key has been replaced
  if grep -q -E "^\s*signingkey\s*=\s*YOUR_SSH_PUBLIC_KEY_HERE" "$HOME/.gitconfig.local"; then
    log "⚠️  Placeholder key still found. Please complete the setup manually."
  else
    log "✅ SSH signing key has been updated!"
  fi
else
    log "✅ SSH signing key already configured in ~/.gitconfig.local. Skipping."
fi

# Set up GitHub CLI authentication with 1Password
log "🐙 Setting up GitHub CLI authentication with 1Password..."
save_step "github_cli_auth"

# Check if 1Password CLI is available and user is signed in
if command -v op &> /dev/null; then
  if op account list &> /dev/null; then
    log "✅ 1Password CLI is available and signed in"
    
    # Check if GitHub plugin is already configured
    if op plugin list | grep -q "github"; then
      log "✅ GitHub CLI is already authenticated with 1Password"
    else
      log "🔧 Setting up GitHub CLI with 1Password shell plugin..."
      log ""
      log "This will:"
      log "• Create/use a GitHub Personal Access Token in 1Password"
      log "• Configure GitHub CLI to use 1Password for authentication"
      log "• Enable biometric authentication for GitHub operations"
      log ""
      read -r -p "Do you want to set up GitHub CLI with 1Password? (Y/n): " setup_gh_auth
      
      if [[ "${setup_gh_auth}" =~ ^[Nn]$ ]]; then
        log "⏭️  Skipping GitHub CLI 1Password setup"
      else
        log "🔧 Initializing GitHub plugin for 1Password..."
        if op plugin init gh; then
          log "✅ GitHub CLI plugin initialized successfully"
          log "💡 You can now use 'gh' commands with biometric authentication"
        else
          log "⚠️  GitHub CLI plugin setup failed - you can set this up manually later"
          log "💡 Run 'op plugin init gh' to set up GitHub CLI authentication"
        fi
      fi
    fi
  else
    log "⚠️  1Password CLI is available but not signed in"
    log "💡 Sign in to 1Password CLI first, then run 'op plugin init gh' for GitHub authentication"
  fi
else
  log "⚠️  1Password CLI not found - GitHub CLI will use standard authentication"
  log "💡 You can authenticate GitHub CLI manually with 'gh auth login'"
fi

# Install Oh My Zsh (if not present)
# It creates a default ~/.zshrc which we'll overwrite next.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  log "🎩 Installing Oh My Zsh..."
  save_step "oh_my_zsh"
  # Run non-interactively, don't try to change shell
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  log "🎩 Oh My Zsh already installed."
fi

# Reload zsh config to apply changes including ASDF path
log "🔄 Reloading Zsh configuration... is not possible from a bash script. Please restart your terminal or open a new zsh session."

log "🧹 Cleaning up Homebrew cache..."
save_step "cleanup"
brew cleanup

save_step "complete"
log "✅ Setup complete! Please restart your terminal for all changes to take effect."

log -e "\n\n🔑 FINAL STEP: SSH SIGNING KEY SETUP"
log "---------------------------------------------------------------------"
log "Your Git configuration is ready, but you need to add your SSH signing key."
log ""
log "📝 QUICK SETUP:"
log "1. Run: ssh-add -L"
log "2. Copy one of the SSH keys (the full line)"
log "3. Edit ~/.gitconfig.local and replace 'YOUR_SSH_PUBLIC_KEY_HERE' with your key"
log ""
log "🛠️  ALTERNATIVE: Run './setup-ssh-signing.sh' for interactive setup"
log ""
log "✅ Your ~/.gitconfig.local file has been created with good defaults including:"
log "   • Useful Git aliases (co, br, ci, st, lg, etc.)"
log "   • Smart push/pull behavior"
log "   • VS Code/Cursor integration for diffs and merges"
log "   • macOS keychain integration"
log "---------------------------------------------------------------------\n"

# Run health check
log "🩺 Running post-installation health check..."
if ./doctor.sh; then
  log "🎉 Health check passed! Your environment is ready to go."
else
  log "⚠️  Health check found some issues. Please review the output above."
  log "💡 You can run './doctor.sh' anytime to check your environment health."
fi

# Clean up step tracking
rm -f "$STEP_FILE"
