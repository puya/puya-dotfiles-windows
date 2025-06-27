# -------------------------------
# 🚀 UV Python Package Manager  
# -------------------------------

# UV environment variables for better performance and behavior
export UV_COMPILE_BYTECODE=1        # Compile Python bytecode for faster imports
export UV_LINK_MODE=copy           # Use copy mode for more reliable installs
export UV_PYTHON_PREFERENCE=only-managed  # Prefer UV-managed Python versions

# Add UV completions if available
if command -v uv &> /dev/null; then
    eval "$(uv generate-shell-completion zsh)"
fi

# UV helper functions
function uv-init() {
    # Initialize a new Python project with UV
    local project_name=${1:-$(basename $PWD)}
    local python_version=${2:-3.12}
    
    echo "🚀 Initializing UV project: $project_name (Python $python_version)"
    uv init "$project_name" --python "$python_version"
    
    if [[ "$project_name" != "$(basename $PWD)" ]]; then
        cd "$project_name"
    fi
    
    echo "✅ Project initialized! Use 'uv add <package>' to install dependencies"
}

function uv-sync-all() {
    # Sync UV project and install all dependency groups
    echo "🔄 Syncing UV project..."
    uv sync --all-extras --dev
}

function uv-clean() {
    # Clean UV cache and temporary files
    echo "🧹 Cleaning UV cache..."
    uv cache clean
    echo "✅ UV cache cleaned"
}

# Aliases for common UV commands
alias uvr="uv run"
alias uva="uv add"
alias uvad="uv add --dev"
alias uvs="uv sync"
alias uvsd="uv sync --dev"
alias uvi="uv init"
alias uvl="uv lock"
alias uvt="uv tool"
alias uvx="uvx"  # Quick run command 