# Environment Variables and PATH modifications

# Editor config (local vs remote)
# When SSH'd into a remote machine, use vim (always available)
# When working locally, use VS Code/Cursor (your preferred editor)
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='cursor'  # or 'code' if you prefer VS Code
fi

# Compilation flags for native architecture
# This tells compilers to build for your specific CPU architecture
# Important for M1/M2 Macs vs Intel Macs
export ARCHFLAGS="-arch $(uname -m)"

# 1Password SSH Agent Socket
# This tells SSH to use 1Password as the SSH agent for key management
# Must be the LAST definition of SSH_AUTH_SOCK to override system defaults
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Windsurf AI Editor (from Codeium)
# Adds Windsurf CLI tools to your PATH
export PATH="/Users/puya/.codeium/windsurf/bin:$PATH"

# Optional: Disable Homebrew analytics (privacy)
export HOMEBREW_NO_ANALYTICS=1

# Optional: Make less more friendly for non-text input files
export LESSOPEN="| /usr/bin/lesspipe %s"
export LESSCLOSE="/usr/bin/lesspipe %s %s" 