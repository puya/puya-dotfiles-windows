#!/bin/bash

# -------------------------------
# 🩺 DOTFILES HEALTH CHECK DOCTOR
# -------------------------------

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0

# Helper functions
print_header() {
  echo -e "\n${BLUE}=== $1 ===${NC}"
}

check_pass() {
  echo -e "${GREEN}✅ $1${NC}"
  ((CHECKS_PASSED++))
}

check_fail() {
  echo -e "${RED}❌ $1${NC}"
  ((CHECKS_FAILED++))
}

check_warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
  ((CHECKS_WARNING++))
}

check_command() {
  local cmd="$1"
  local name="$2"
  local required="${3:-true}"
  
  if command -v "$cmd" &> /dev/null; then
    local version
    case "$cmd" in
      "brew") version=$(brew --version | head -n1) ;;
      "git") version=$(git --version) ;;
      "node") version="Node.js $(node --version)" ;;
      "python") version="Python $(python --version 2>&1)" ;;
      "asdf") version="ASDF $(asdf version)" ;;
      *) version="$($cmd --version 2>&1 | head -n1)" ;;
    esac
    check_pass "$name is installed: $version"
    return 0
  else
    if [[ "$required" == "true" ]]; then
      check_fail "$name is not installed"
    else
      check_warn "$name is not installed (optional)"
    fi
    return 1
  fi
}

check_file() {
  local file="$1"
  local name="$2"
  local required="${3:-true}"
  
  if [[ -f "$file" ]]; then
    check_pass "$name exists: $file"
    return 0
  else
    if [[ "$required" == "true" ]]; then
      check_fail "$name is missing: $file"
    else
      check_warn "$name is missing: $file (optional)"
    fi
    return 1
  fi
}

check_symlink() {
  local link="$1"
  local name="$2"
  
  if [[ -L "$link" ]]; then
    local target=$(readlink "$link")
    check_pass "$name is properly symlinked: $link -> $target"
    return 0
  elif [[ -f "$link" ]]; then
    check_warn "$name exists but is not a symlink: $link"
    return 1
  else
    check_fail "$name is missing: $link"
    return 1
  fi
}

# -------------------------------
# 🔍 SYSTEM CHECKS
# -------------------------------

print_header "System Information"
echo "Platform: $(uname -s) $(uname -m)"
echo "Shell: $SHELL"
echo "Home: $HOME"
echo "User: $(whoami)"

# -------------------------------
# 🍺 HOMEBREW CHECKS
# -------------------------------

print_header "Homebrew"
if check_command "brew" "Homebrew"; then
  # Check Homebrew health
  if brew doctor &> /dev/null; then
    check_pass "Homebrew doctor reports no issues"
  else
    check_warn "Homebrew doctor found some issues (run 'brew doctor' for details)"
  fi
  
  # Check if Brewfile exists and is valid
  if check_file "$HOME/Brewfile" "Brewfile"; then
    if brew bundle check --file="$HOME/Brewfile" &> /dev/null; then
      check_pass "All Brewfile packages are installed"
    else
      check_warn "Some Brewfile packages are missing (run 'brew bundle install' to fix)"
    fi
  fi
fi

# -------------------------------
# 🔧 CORE TOOLS CHECKS
# -------------------------------

print_header "Core Development Tools"
check_command "git" "Git"
check_command "gh" "GitHub CLI"
check_command "curl" "cURL"
check_command "asdf" "ASDF"

# -------------------------------
# 🐍 PYTHON & UV CHECKS
# -------------------------------

print_header "Python Environment"
check_command "python" "Python"
check_command "python3" "Python3"
check_command "pip" "pip" false
check_command "poetry" "Poetry"
check_command "uv" "uv"

if command -v python &> /dev/null; then
  python_version=$(python --version 2>&1 | awk '{print $2}')
  expected_version=$(grep "^python" ~/.tool-versions 2>/dev/null | awk '{print $2}')
  if [[ -n "$expected_version" ]]; then
    if [[ "$expected_version" == "$python_version"* ]]; then
      check_pass "Python version matches .tool-versions: $python_version"
    else
      check_warn "Python version mismatch. Expected: $expected_version, Got: $python_version"
    fi
  fi
fi

# -------------------------------
# 🟢 NODE.JS CHECKS
# -------------------------------

print_header "Node.js Environment"
if check_command "node" "Node.js"; then
    check_command "npm" "npm"
    check_command "npx" "npx" false

    node_version=$(node --version)
    expected_version=$(grep "^nodejs" ~/.tool-versions 2>/dev/null | awk '{print $2}')
    
    # Handle 'lts' keyword for nodejs
    if [[ "$expected_version" == "lts" ]]; then
        lts_version=$(asdf latest nodejs lts 2>/dev/null || echo "")
        if [[ -n "$lts_version" && "$node_version" == "v$lts_version" ]]; then
            check_pass "Node.js version matches .tool-versions (lts -> v$lts_version): $node_version"
        else
            check_warn "Node.js version mismatch. Expected lts, Got: $node_version"
        fi
    elif [[ -n "$expected_version" ]]; then
        if [[ "$node_version" == "v$expected_version" ]]; then
            check_pass "Node.js version matches .tool-versions: $node_version"
        else
            check_warn "Node.js version mismatch. Expected: v$expected_version, Got: $node_version"
        fi
    fi
fi

# -------------------------------
# 📁 DOTFILES CHECKS
# -------------------------------

print_header "Dotfiles Configuration"
check_symlink "$HOME/.zshrc" "ZSH configuration"
check_symlink "$HOME/.gitconfig" "Git configuration"
check_symlink "$HOME/.tool-versions" "ASDF tool versions"
check_symlink "$HOME/Brewfile" "Homebrew bundle file"

# Check if zsh modules are properly linked
if [[ -L "$HOME/zsh" ]]; then
  check_pass "ZSH modules directory is symlinked"
  for module in 01-exports 02-asdf 10-aliases 11-functions; do
    if [[ -f "$HOME/zsh/$module.zsh" ]]; then
      check_pass "ZSH module exists: $module.zsh"
    else
      check_fail "ZSH module missing: $module.zsh"
    fi
  done
else
  check_fail "ZSH modules directory is not symlinked"
fi

# -------------------------------
# 🔐 GIT & SSH CHECKS
# -------------------------------

print_header "Git & SSH Configuration"
if command -v git &> /dev/null; then
  # Check git user configuration
  git_name=$(git config --global user.name 2>/dev/null)
  git_email=$(git config --global user.email 2>/dev/null)
  
  if [[ -n "$git_name" ]]; then
    check_pass "Git user name is configured: $git_name"
  else
    check_fail "Git user name is not configured"
  fi
  
  if [[ -n "$git_email" ]]; then
    check_pass "Git user email is configured: $git_email"
  else
    check_fail "Git user email is not configured"
  fi
  
  # Check git signing configuration
  if git config --global commit.gpgsign | grep -q "true"; then
    check_pass "Git commit signing is enabled"
    
    # Check if signing key is configured
    if check_file "$HOME/.gitconfig.local" "Git local config (for signing key)"; then
      if grep -q -E "^\s*signingkey\s*=\s*YOUR_SSH_PUBLIC_KEY_HERE" "$HOME/.gitconfig.local"; then
        check_fail "Git signing key placeholder not replaced in ~/.gitconfig.local"
        echo "  💡 Edit ~/.gitconfig.local and replace 'YOUR_SSH_PUBLIC_KEY_HERE' with your actual SSH key"
        echo "  💡 Get your key with: ssh-add -L"
      elif grep -q "signingkey.*ssh-" "$HOME/.gitconfig.local"; then
        check_pass "Git signing key is configured in ~/.gitconfig.local"
      else
        check_warn "Git signing key may not be properly configured in ~/.gitconfig.local"
      fi
    fi
  else
    check_warn "Git commit signing is not enabled"
  fi
fi

# Check SSH agent (1Password)
if [[ -n "$SSH_AUTH_SOCK" ]]; then
  check_pass "SSH_AUTH_SOCK is configured: $SSH_AUTH_SOCK"
  if ssh-add -L &> /dev/null; then
    key_count=$(ssh-add -L | wc -l)
    check_pass "SSH agent has $key_count key(s) loaded"
  else
    check_fail "SSH agent is configured but no keys are loaded"
    echo "  💡 Run './setup-ssh-signing.sh' to troubleshoot SSH key setup"
  fi
else
  check_warn "SSH_AUTH_SOCK is not configured"
fi

# -------------------------------
# 🎩 ZSH & OH-MY-ZSH CHECKS
# -------------------------------

print_header "Shell Configuration"
if [[ "$SHELL" == *"zsh"* ]]; then
  check_pass "ZSH is the default shell"
else
  check_warn "ZSH is not the default shell (current: $SHELL)"
fi

if [[ -d "$HOME/.oh-my-zsh" ]]; then
  check_pass "Oh My Zsh is installed"
else
  check_fail "Oh My Zsh is not installed"
fi

# Check if ASDF is properly sourced
if [[ -n "$ASDF_DIR" ]] || command -v asdf &> /dev/null; then
  check_pass "ASDF is properly loaded in shell"
else
  check_warn "ASDF may not be properly loaded in shell"
fi

# -------------------------------
# 📊 SUMMARY
# -------------------------------

print_header "Health Check Summary"
total_checks=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))

echo -e "${GREEN}✅ Passed: $CHECKS_PASSED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $CHECKS_WARNING${NC}"
echo -e "${RED}❌ Failed: $CHECKS_FAILED${NC}"
echo "Total checks: $total_checks"

if [[ $CHECKS_FAILED -eq 0 ]]; then
  echo -e "\n${GREEN}🎉 Your development environment looks healthy!${NC}"
  if [[ $CHECKS_WARNING -gt 0 ]]; then
    echo -e "${YELLOW}Consider addressing the warnings above for optimal setup.${NC}"
  fi
  exit 0
else
  echo -e "\n${RED}🚨 Your development environment has some issues that need attention.${NC}"
  echo -e "${BLUE}💡 Consider running './init.sh' to fix missing components.${NC}"
  exit 1
fi 