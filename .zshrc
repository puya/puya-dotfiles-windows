# -------------------------------
# 🔧 ACTIVE CONFIGURATION
# -------------------------------

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme (try others like "agnoster" or "powerlevel10k")
ZSH_THEME="robbyrussell"

# Plugins to load
plugins=(git)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Initialize asdf (for managing Node, Python, etc.)
. $(brew --prefix asdf)/libexec/asdf.sh

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
