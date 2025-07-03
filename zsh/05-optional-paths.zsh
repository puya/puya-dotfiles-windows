#!/usr/bin/env zsh
# Optional tool paths - only added if tools are installed
# Safe to sync across devices - uses conditional checks

# John the Ripper utilities
[[ -d "/opt/homebrew/share/john" ]] && export PATH="/opt/homebrew/share/john:$PATH"

# Token Counter
[[ -d "/Users/puya/token-counter/.venv/bin" ]] && export PATH="/Users/puya/token-counter/.venv/bin:$PATH"

# Add more optional tools here as needed
# Examples:
# [[ -d "/opt/homebrew/opt/postgresql@15/bin" ]] && export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
# [[ -d "/usr/local/go/bin" ]] && export PATH="/usr/local/go/bin:$PATH"
# [[ -d "$HOME/.cargo/bin" ]] && export PATH="$HOME/.cargo/bin:$PATH" 