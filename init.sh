#!/bin/bash
set -e

echo "🛠️  Starting system setup..."

# Install Homebrew if not already installed
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "🍺 Homebrew already installed."
fi

echo "🍺 Installing core packages with Homebrew..."
brew install git gh asdf curl uv

# Add ASDF to shell if not already there
# We'll source the final .zshrc later, which should contain this.
# if ! grep -q 'asdf.sh' ~/.zshrc; then
#   echo "⚙️  Adding ASDF to your shell config..."
#   echo -e '\\n. $(brew --prefix asdf)/libexec/asdf.sh' >> ~/.zshrc
# fi

echo "📦 Setting up ASDF..."
# Temporarily source asdf for this script session
. "$(brew --prefix asdf)/libexec/asdf.sh" || echo "Failed to source ASDF for init script, continuing..."

asdf plugin add python || echo "✅ Python plugin already added"
asdf plugin add nodejs || echo "✅ NodeJS plugin already added"
asdf plugin add poetry || echo "✅ Poetry plugin already added"
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
echo "🔄 Reloading Zsh configuration..."
source ~/.zshrc || echo "⚠️  Could not source ~/.zshrc. Please restart your terminal."

echo "✅ Setup complete! Please restart your terminal for all changes to take effect."
