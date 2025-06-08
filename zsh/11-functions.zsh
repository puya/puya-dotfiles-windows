# Useful shell functions

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find and kill process by name
killport() {
  if [ -z "$1" ]; then
    echo "Usage: killport <port_number>"
    return 1
  fi
  lsof -ti:$1 | xargs kill -9
}

# Git diff with diff-so-fancy (if available)
dif() {
  if command -v diff-so-fancy &> /dev/null; then
    git diff --color --no-index "$1" "$2" | diff-so-fancy
  else
    git diff --color --no-index "$1" "$2"
  fi
}

# Quick project setup
newproject() {
  if [ -z "$1" ]; then
    echo "Usage: newproject <project_name>"
    return 1
  fi
  mkcd "$1"
  git init
  echo "# $1" > README.md
  echo "node_modules/\n.env\n.DS_Store" > .gitignore
  echo "Project $1 created and initialized!"
} 