#!/bin/bash
set -e

echo "🛠️  Starting system setup..."

# Install Homebrew if not already installed
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for the current script session
  if [ -x "/opt/homebrew/bin/brew" ]; then # Apple Silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x "/usr/local/bin/brew" ]; then # Intel
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  echo "🍺 Homebrew already installed."
  read -r -p "🤔 Do you want to update Homebrew? (yes/no): " update_brew_confirmation
  if [[ "$update_brew_confirmation" == "yes" ]]; then
    echo "🍺 Updating Homebrew..."
    brew update
  else
    echo "🍺 Skipping Homebrew update."
  fi
fi

echo "🍺 Installing core packages with Homebrew..."
brew install git gh asdf curl git-lfs

# --- Critical Git Authentication Setup for Private Repositories ---
echo "🤔 Checking existing Git configuration..."

GITCONFIG_SYMLINK_TARGET="$(pwd)/.gitconfig"

if [ -L ~/.gitconfig ] && [ "$(readlink ~/.gitconfig)" = "$GITCONFIG_SYMLINK_TARGET" ]; then
  echo "✅ ~/.gitconfig is already correctly symlinked to your dotfiles."
  echo "   Assuming 1Password SSH authentication via ~/.gitconfig.local is configured."
  echo "   Skipping manual SSH key setup steps."
else
  echo "🔒 Git configuration needs attention for private repository access..."
  # Check if .gitconfig exists in the dotfiles directory
  if [ ! -f ".gitconfig" ]; then
    echo "❌ ERROR: Your .gitconfig file is missing from the dotfiles directory."
    echo "   This file is crucial for setting up Git user identity and 1Password SSH signing."
    echo "   Please ensure .gitconfig is present in your dotfiles repository and run the script again."
    exit 1
  fi

  echo "   Temporarily symlinking your .gitconfig to ~/.gitconfig..."
  # Remove existing ~/.gitconfig if it's a symlink or regular file to avoid ln error
  if [ -L ~/.gitconfig ] || [ -e ~/.gitconfig ]; then
    rm -f ~/.gitconfig
  fi
  ln -s "$GITCONFIG_SYMLINK_TARGET" ~/.gitconfig
  echo "   ✅ Your .gitconfig has been temporarily linked."
  echo ""
  echo "⚠️  ACTION REQUIRED: Configure SSH Key for Git & 1Password ⚠️"
  echo "---------------------------------------------------------------------"
  echo "Your dotfiles repository or its submodules (like dotbot) may be private."
  echo "To allow this script to securely access them using your SSH key via 1Password,"
  echo "please follow these steps CAREFULLY in a NEW terminal window:"
  echo ""
  echo "1. Ensure the 1Password desktop application is running and unlocked."
  echo "2. In 1Password App: Go to Settings > Developer, and ensure 'Use the SSH Agent' is ENABLED."
  echo "3. In a NEW terminal, run: ssh-add -L"
  echo "   This lists SSH keys 1Password agent provides. Identify your desired Git signing/authentication key."
  echo "   It will look like: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-key-comment"
  echo ""
  echo "4. Create or edit the file ~/.gitconfig.local (in your home directory)."
  echo "   Add the following line, replacing the example with YOUR FULL public key string from step 3:"
  echo "   [user]"
  echo "     signingkey = ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your-key-comment"
  echo ""
  echo "5. Save ~/.gitconfig.local."
  echo "---------------------------------------------------------------------"
  read -r -p "✅ Have you completed these steps and saved ~/.gitconfig.local? (yes/no): " confirmation
  if [[ "$confirmation" != "yes" ]]; then
    echo "🛑 Setup paused. Please complete the steps above to continue."
    echo "   Re-run this script once ~/.gitconfig.local is correctly set up."
    exit 1
  fi
  echo "👍 Great! Proceeding with the rest of the setup..."
fi
# --- Git Authentication Setup Done ---

echo "📦 Setting up ASDF..."
# Temporarily source asdf for this script session
. "$(brew --prefix asdf)/libexec/asdf.sh" || echo "Failed to source ASDF for init script, continuing..."

asdf plugin add python || echo "✅ Python plugin already added"
asdf plugin add nodejs || echo "✅ NodeJS plugin already added"
asdf plugin add poetry || echo "✅ Poetry plugin already added"

echo "📦 Setting up uv with ASDF..."
asdf plugin add uv || echo "✅ uv plugin already added or failed to add"
asdf install uv latest || echo "⚠️  Failed to install latest uv. This might require uv to be added to .tool-versions first, or check plugin."
asdf set uv latest || echo "⚠️  Failed to set uv version with 'asdf set'. This would update ~/.tool-versions."

asdf install || echo "⚠️  ASDF install command finished (check output for errors)."

# Install Oh My Zsh (if not present)
# It creates a default ~/.zshrc which we'll overwrite next.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🎩 Installing Oh My Zsh..."
  # Run non-interactively, don't try to change shell
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "🎩 Oh My Zsh already installed."
fi

# Run dotfiles linking script (which now forces overwrite)
echo "🔗 Linking dotfiles with Dotbot..."
./link-dotfiles.sh # Use the renamed script

# Reload zsh config to apply changes including ASDF path
echo "🔄 Reloading Zsh configuration... is not possible from a bash script. Please restart your terminal or open a new zsh session."

echo "🧹 Cleaning up Homebrew cache..."
brew cleanup

echo "✅ Setup complete! Please restart your terminal for all changes to take effect."

echo -e "\n\n⚠️ IMPORTANT GIT SIGNING SETUP ⚠️"
echo "---------------------------------------------------------------------"
echo "Your Git configuration is set up to sign commits using SSH via 1Password."
echo "To complete this setup, you MUST create or verify the file ~/.gitconfig.local"
echo "with your specific SSH signing key."
echo ""
echo "👉 Please see the 'IMPORTANT: Setting Up Git Commit Signing' section in"
echo "   dev-setup.md for detailed step-by-step instructions."
echo "---------------------------------------------------------------------\n"
