# Aliases and shortcuts

# Config editing shortcuts
alias zshconfig="code ~/.zshrc"
alias ohmyzsh="code ~/.oh-my-zsh"
alias dotfiles="cd ~/dotfiles && code ."

# Git shortcuts
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline --graph --decorate"

# Directory navigation
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"

# Modern replacements (if installed via Brewfile)
if command -v eza &> /dev/null; then
  alias ls="eza"
  alias ll="eza -la"
  alias tree="eza --tree"
fi

if command -v bat &> /dev/null; then
  alias cat="bat"
fi

# Development shortcuts
alias serve="python -m http.server 8000"
alias myip="curl http://ipecho.net/plain; echo"

# Homebrew shortcuts
alias brewup="brew update && brew upgrade && brew cleanup"
alias brewdump="brew bundle dump --force --describe" 