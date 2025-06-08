# ASDF Version Manager Configuration

# Initialize asdf (for managing Node, Python, etc.)
if command -v brew &> /dev/null; then
  . "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# ASDF completions
if [ -f "$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" ]; then
  . "$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash"
fi

# Auto-install missing tools when entering directories with .tool-versions
export ASDF_INSTALL_MISSING_TOOLS=yes 