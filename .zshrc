# -------------------------------
# 🔧 PUYA'S ZSH CONFIGURATION
# -------------------------------

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme (try others like "agnoster" or "powerlevel10k")
ZSH_THEME="robbyrussell"

# Plugins to load
plugins=(git asdf)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# -------------------------------
# 📦 MODULAR CONFIGURATION
# -------------------------------

# Get the directory where this .zshrc file is located
DOTFILES_DIR="$(dirname "$(readlink ~/.zshrc 2>/dev/null || echo ~/.zshrc)")"

# Source modular configuration files
for config_file in "$HOME/.zsh"/*.zsh; do
  if [[ -r "$config_file" ]]; then
    source "$config_file"
  fi
done

# -------------------------------
# 🎯 LOCAL OVERRIDES
# -------------------------------

# Source local configuration if it exists (machine-specific settings)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# -------------------------------
# 📎 OPTIONAL SETTINGS & NOTES
# (Reference only - not active)
# -------------------------------

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Set list of themes to pick from when loading at random
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment to use hyphen-insensitive completion.
# HYPHEN_INSENSITIVE="true"

# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # auto-update without asking
# zstyle ':omz:update' mode reminder  # remind to update when it's time
# zstyle ':omz:update' frequency 13   # change auto-update frequency (days)

# Uncomment if pasting text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment to disable setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment to show red dots while waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment to disable marking untracked files in Git
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment to change history timestamps
# HIST_STAMPS="yyyy-mm-dd"

# Use another custom folder than $ZSH/custom
# ZSH_CUSTOM=/path/to/new-custom-folder

# Editor config (local vs remote)
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Example aliases
# alias zshconfig="code ~/.zshrc"
# alias ohmyzsh="code ~/.oh-my-zsh"

# Added by Windsurf
export PATH="/Users/puya/.codeium/windsurf/bin:$PATH"

# 1Password SSH Agent Sock (ensure this is the LAST definition of this var)
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
source /Users/puya/.config/op/plugins.sh
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/puya/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
