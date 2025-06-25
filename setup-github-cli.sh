#!/bin/bash

# 🐙 GitHub CLI Authentication Setup Helper for 1Password
# This script helps you configure GitHub CLI with 1Password for secure authentication

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
  echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
  echo -e "${RED}❌ $1${NC}"
}

print_info() {
  echo -e "${BLUE}ℹ️  $1${NC}"
}

print_header "GitHub CLI Authentication Setup"

# Check prerequisites
print_header "Checking Prerequisites"

if ! command -v gh &> /dev/null; then
  print_error "GitHub CLI (gh) is not installed"
  echo "Install with: brew install gh"
  exit 1
fi
print_success "GitHub CLI is installed"

if ! command -v op &> /dev/null; then
  print_error "1Password CLI is not installed"
  echo "Install with: brew install 1password-cli"
  exit 1
fi
print_success "1Password CLI is installed"

# Check if 1Password CLI is signed in
if ! op account list &> /dev/null; then
  print_error "1Password CLI is not signed in"
  echo "Sign in with: op signin"
  exit 1
fi
print_success "1Password CLI is signed in"

print_header "Current GitHub CLI Status"

# Check current GitHub CLI authentication status
if gh auth status &> /dev/null; then
  print_warning "GitHub CLI is already authenticated"
  echo "Current status:"
  gh auth status
  echo ""
  read -p "Do you want to reconfigure GitHub CLI authentication? (y/N): " reconfigure
  if [[ "$reconfigure" != "y" && "$reconfigure" != "Y" ]]; then
    print_info "Keeping existing GitHub CLI authentication"
    exit 0
  fi
else
  print_info "GitHub CLI is not currently authenticated"
fi

print_header "Authentication Options"

echo "You have two main options for GitHub CLI authentication:"
echo ""
echo "1. 🔐 1Password Shell Plugin (Recommended)"
echo "   • Uses Personal Access Token stored in 1Password"
echo "   • Biometric authentication for each use"
echo "   • Seamless integration with your existing 1Password setup"
echo ""
echo "2. 🔑 SSH Authentication"
echo "   • Uses your existing SSH keys from 1Password SSH agent"
echo "   • Leverages your current SSH setup"
echo "   • No separate token needed"
echo ""

read -p "Which option would you prefer? (1 for 1Password Plugin, 2 for SSH): " auth_choice

case $auth_choice in
  1)
    print_header "Setting up 1Password Shell Plugin"
    
    # Check if plugin is already configured
    if op plugin list 2>/dev/null | grep -q "github"; then
      print_warning "GitHub plugin is already configured"
      op plugin inspect gh
      echo ""
      read -p "Do you want to reconfigure the plugin? (y/N): " reconfig_plugin
      if [[ "$reconfig_plugin" != "y" && "$reconfig_plugin" != "Y" ]]; then
        print_info "Keeping existing plugin configuration"
        exit 0
      fi
      print_info "Clearing existing plugin configuration..."
      op plugin clear gh --all
    fi
    
    print_info "Initializing GitHub plugin..."
    echo ""
    echo "You'll be prompted to:"
    echo "• Create or select a GitHub Personal Access Token in 1Password"
    echo "• Choose when to use the credentials (global/directory/session)"
    echo ""
    
    if op plugin init gh; then
      print_success "GitHub plugin initialized successfully!"
      
      # Source the plugins file
      PLUGINS_FILE="$HOME/.config/op/plugins.sh"
      if [[ -f "$PLUGINS_FILE" ]]; then
        print_info "Sourcing 1Password plugins for this session..."
        source "$PLUGINS_FILE"
        
        # Add to shell profile if not already there
        SHELL_RC=""
        if [[ "$SHELL" == *"zsh"* ]]; then
          SHELL_RC="$HOME/.zshrc"
        elif [[ "$SHELL" == *"bash"* ]]; then
          SHELL_RC="$HOME/.bash_profile"
        fi
        
        if [[ -n "$SHELL_RC" ]] && [[ -f "$SHELL_RC" ]]; then
          if ! grep -q "source.*plugins.sh" "$SHELL_RC"; then
            echo "" >> "$SHELL_RC"
            echo "# 1Password shell plugins" >> "$SHELL_RC"
            echo "source $PLUGINS_FILE" >> "$SHELL_RC"
            print_success "Added 1Password plugins to $SHELL_RC"
          fi
        fi
      fi
      
      print_header "Testing Authentication"
      print_info "Testing GitHub CLI with 1Password authentication..."
      if gh auth status; then
        print_success "GitHub CLI is now authenticated with 1Password!"
      else
        print_warning "Authentication test failed - you may need to restart your terminal"
      fi
      
    else
      print_error "Failed to initialize GitHub plugin"
      exit 1
    fi
    ;;
    
  2)
    print_header "Setting up SSH Authentication"
    
    # Check if SSH keys are available
    if ! ssh-add -L &> /dev/null; then
      print_error "No SSH keys found in 1Password SSH agent"
      echo "Make sure:"
      echo "• 1Password desktop app is running"
      echo "• SSH agent is enabled in 1Password settings"
      echo "• You have SSH keys stored in 1Password"
      exit 1
    fi
    
    print_success "SSH keys found in 1Password agent"
    
    print_info "Authenticating GitHub CLI with SSH..."
    if gh auth login -p ssh; then
      print_success "GitHub CLI authenticated with SSH!"
      
      print_header "Configuring Git to use GitHub CLI"
      print_info "Setting up Git to use GitHub CLI for authentication..."
      if gh auth setup-git; then
        print_success "Git configured to use GitHub CLI for authentication"
      else
        print_warning "Failed to configure Git - you may need to do this manually"
      fi
      
    else
      print_error "Failed to authenticate with SSH"
      exit 1
    fi
    ;;
    
  *)
    print_error "Invalid choice. Please run the script again and choose 1 or 2."
    exit 1
    ;;
esac

print_header "Setup Complete!"
print_success "GitHub CLI is now configured with your chosen authentication method"

echo ""
print_info "Next steps:"
echo "• Test with: gh repo list"
echo "• For Git operations: git clone git@github.com:user/repo.git"
echo "• Run './doctor.sh' to verify your complete setup"

if [[ $auth_choice == 1 ]]; then
  echo ""
  print_info "With 1Password plugin:"
  echo "• You'll be prompted for biometric authentication when using gh commands"
  echo "• Your Personal Access Token is securely stored in 1Password"
  echo "• Use 'op plugin inspect gh' to view your configuration"
fi 