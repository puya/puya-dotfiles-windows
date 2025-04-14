#!/bin/bash
set -e

echo "🛠️  Starting system setup..."

# Install Homebrew if not already installed
if ! command -v brew &>/dev/null; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "🍺 Installing core packages with Homebrew..."
brew install git gh asdf curl

# Add ASDF to shell if not already there
if ! grep -q 'asdf.sh' ~/.zshrc; then
  echo "⚙️  Adding ASDF to your shell config..."
  echo -e '\n. $(brew --prefix asdf)/libexec/asdf.sh' >> ~/.zshrc
fi

# Initialize ASDF and install plugins
echo "📦 Setting up ASDF..."
. "$(brew --prefix asdf)/libexec/asdf.sh"

asdf plugin add python || echo "✅ Python already added"
asdf plugin add nodejs || echo "✅ NodeJS already added"
asdf install

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "🎩 Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Run dotfiles install
echo "🔗 Linking dotfiles with Dotbot..."
./install

echo "✅ Setup complete!"
