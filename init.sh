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
if ! command -v brew &>/dev/null; then
  log "🍺 Installing Homebrew..."
  save_step "homebrew_install"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for the current script session
  if [ -x "$HOMEBREW_PREFIX/bin/brew" ]; then
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
  fi
else
  log "🍺 Homebrew already installed."
  read -r -p "🤔 Do you want to update Homebrew? (yes/no): " update_brew_confirmation
  if [[ "$update_brew_confirmation" == "yes" ]]; then
    log "🍺 Updating Homebrew..."
    save_step "homebrew_update"
    brew update
  else
    log "🍺 Skipping Homebrew update."
  fi
fi

log "🍺 Installing packages with Homebrew Bundle..."
save_step "homebrew_packages"
if [[ -f "Brewfile" ]]; then
  # Install missing packages and upgrade existing ones
  brew bundle --file=Brewfile
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
  log ""
  log "⚠️  ACTION REQUIRED: Configure SSH Key for Git & 1Password ⚠️"
  log "---------------------------------------------------------------------"
  log "Your dotfiles repository or its submodules (like dotbot) may be private."
  log "To allow this script to securely access them using your SSH key via 1Password,"
  log "please follow these steps CAREFULLY in a NEW terminal window:"
  log ""
  log "1. Ensure the 1Password desktop application is running and unlocked."
  log "2. In 1Password App: Go to Settings > Developer, and ensure 'Use the SSH Agent' is ENABLED."
  log "3. In a NEW terminal, run: ssh-add -L"
  log "   This lists SSH keys 1Password agent provides. Identify your desired Git signing/authentication key."
  log "   It will look like: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-key-comment"
  log ""
  log "4. Create or edit the file ~/.gitconfig.local (in your home directory)."
  log "   Add the following line, replacing the example with YOUR FULL public key string from step 3:"
  log "   [user]"
  log "     signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-key-comment"
  log ""
  log "5. Save ~/.gitconfig.local."
  log "---------------------------------------------------------------------"
  read -r -p "✅ Have you completed these steps and saved ~/.gitconfig.local? (yes/no): " confirmation
  if [[ "$confirmation" != "yes" ]]; then
    log "🛑 Setup paused. Please complete the steps above to continue."
    log "   Re-run this script once ~/.gitconfig.local is correctly set up."
    exit 1
  fi
  log "👍 Great! Proceeding with the rest of the setup..."
fi
# --- Git Authentication Setup Done ---

log "📦 Setting up ASDF..."
save_step "asdf_setup"
# Temporarily source asdf for this script session
. "$(brew --prefix asdf)/libexec/asdf.sh" || log "Failed to source ASDF for init script, continuing..."

asdf plugin add python || log "✅ Python plugin already added"
asdf plugin add nodejs || log "✅ NodeJS plugin already added"
asdf plugin add poetry || log "✅ Poetry plugin already added"

log "📦 Setting up uv with ASDF..."
save_step "uv_setup"
asdf plugin add uv || log "✅ uv plugin already added or failed to add"
asdf install uv latest || log "⚠️  Failed to install latest uv. This might require uv to be added to .tool-versions first, or check plugin."
asdf global uv latest || log "⚠️  Failed to set uv version with 'asdf global'. This would update ~/.tool-versions."

save_step "asdf_install"
asdf install || log "⚠️  ASDF install command finished (check output for errors)."

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

# Run dotfiles linking script (which now forces overwrite)
log "🔗 Linking dotfiles with Dotbot..."
save_step "dotbot_linking"
./link-dotfiles.sh # Use the renamed script

# Reload zsh config to apply changes including ASDF path
log "🔄 Reloading Zsh configuration... is not possible from a bash script. Please restart your terminal or open a new zsh session."

log "🧹 Cleaning up Homebrew cache..."
save_step "cleanup"
brew cleanup

save_step "complete"
log "✅ Setup complete! Please restart your terminal for all changes to take effect."

log -e "\n\n⚠️ IMPORTANT GIT SIGNING SETUP ⚠️"
log "---------------------------------------------------------------------"
log "Your Git configuration is set up to sign commits using SSH via 1Password."
log "To complete this setup, you MUST create or verify the file ~/.gitconfig.local"
log "with your specific SSH signing key."
log ""
log "👉 Please see the 'IMPORTANT: Setting Up Git Commit Signing' section in"
log "   dev-setup.md for detailed step-by-step instructions."
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
