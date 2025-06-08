#!/bin/bash

# 🔐 SSH Signing Setup Helper for 1Password
# This script helps you configure Git commit signing with 1Password SSH agent

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

print_header "SSH Signing Setup for 1Password"

# Check if 1Password SSH agent is configured
if [[ -n "$SSH_AUTH_SOCK" ]] && [[ "$SSH_AUTH_SOCK" == *"1password"* ]]; then
  print_success "1Password SSH agent is configured in your shell"
else
  print_warning "1Password SSH agent may not be configured properly"
  echo "Your SSH_AUTH_SOCK: ${SSH_AUTH_SOCK:-'not set'}"
fi

# Check if SSH config exists
if [[ -f ~/.ssh/config ]]; then
  if grep -q "1password" ~/.ssh/config; then
    print_success "SSH config includes 1Password agent"
  else
    print_warning "SSH config exists but may not include 1Password agent"
  fi
else
  print_info "No SSH config found - this is okay if 1Password manages it"
fi

print_header "Checking for SSH Keys in 1Password"

# Try to list SSH keys
if ssh-add -L &> /dev/null; then
  echo "Available SSH keys from 1Password:"
  ssh-add -L | while IFS= read -r key; do
    key_type=$(echo "$key" | awk '{print $1}')
    key_comment=$(echo "$key" | awk '{print $NF}')
    key_fingerprint=$(echo "$key" | ssh-keygen -lf - | awk '{print $2}')
    echo "  • $key_type ... $key_comment (fingerprint: $key_fingerprint)"
  done
  
  print_header "Setting up .gitconfig.local"
  
  if [[ -f ~/.gitconfig.local ]]; then
    print_warning "~/.gitconfig.local already exists"
    echo "Current content:"
    cat ~/.gitconfig.local
    echo ""
    read -p "Do you want to overwrite it? (y/N): " overwrite
    if [[ "$overwrite" != "y" && "$overwrite" != "Y" ]]; then
      print_info "Keeping existing ~/.gitconfig.local"
      exit 0
    fi
  fi
  
  echo "Available keys:"
  ssh-add -L | nl -w2 -s') '
  echo ""
  read -p "Which key number do you want to use for Git signing? (1-$(ssh-add -L | wc -l)): " key_num
  
  if [[ "$key_num" =~ ^[0-9]+$ ]] && [[ "$key_num" -ge 1 ]] && [[ "$key_num" -le $(ssh-add -L | wc -l) ]]; then
    selected_key=$(ssh-add -L | sed -n "${key_num}p")
    
    # Create .gitconfig.local
    cat > ~/.gitconfig.local << EOF
[user]
  signingkey = $selected_key
EOF
    
    print_success "Created ~/.gitconfig.local with your selected SSH key"
    print_info "You can now use Git with commit signing enabled!"
    
    # Test Git signing
    print_header "Testing Git Configuration"
    if git config --global user.name &> /dev/null && git config --global user.email &> /dev/null; then
      print_success "Git user configuration is set"
      echo "Name: $(git config --global user.name)"
      echo "Email: $(git config --global user.email)"
    else
      print_warning "Git user name/email not configured globally"
    fi
    
    if git config --global commit.gpgsign | grep -q "true"; then
      print_success "Git commit signing is enabled"
    else
      print_warning "Git commit signing is not enabled (this should be set in your main .gitconfig)"
    fi
    
  else
    print_error "Invalid selection. Please run the script again."
    exit 1
  fi
  
else
  print_error "No SSH keys found in 1Password agent"
  echo ""
  print_info "Troubleshooting steps:"
  echo "1. Ensure 1Password desktop app is running and unlocked"
  echo "2. Go to 1Password Settings > Developer > Enable 'Use the SSH Agent'"
  echo "3. Make sure you have SSH keys stored in 1Password"
  echo "4. If you don't have SSH keys, generate one:"
  echo "   ssh-keygen -t ed25519 -C 'your-email@example.com'"
  echo "5. Add the key to 1Password and enable it for SSH agent"
  echo ""
  print_info "After fixing these issues, run this script again"
  exit 1
fi

print_header "Setup Complete!"
print_success "Your Git signing is now configured with 1Password"
echo ""
print_info "Next steps:"
echo "• Test with: git commit --allow-empty -m 'Test signing'"
echo "• Verify with: git log --show-signature -1" 