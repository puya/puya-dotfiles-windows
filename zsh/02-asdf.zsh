# -------------------------------
# 📦 ASDF Version Manager
# -------------------------------

# Source ASDF shell script only if Homebrew-installed asdf exists.
# This avoids errors during initial shell setup before Homebrew is fully configured.
if [ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]; then
  . "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# Optional: Add completions
# This needs to be after the main script is sourced.
# fpath=($(brew --prefix asdf)/etc/zsh/site-functions $fpath)
# autoload -Uz compinit && compinit

# ASDF completions
if [ -f "$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash" ]; then
  . "$(brew --prefix asdf)/etc/bash_completion.d/asdf.bash"
fi

# Auto-install missing tools when entering directories with .tool-versions
export ASDF_INSTALL_MISSING_TOOLS=yes 