#!/bin/bash
set -e

CONFIG_FILE="install.conf.yaml"
echo "🔄 Checking target files specified in $CONFIG_FILE..."

# Extract target paths (like ~/.zshrc)
targets_raw=$(grep '^\s*~/' "$CONFIG_FILE" | sed -E 's/^[[:space:]]*([^:]+):.*/\1/')

abort=false
# Safety check: Abort if any target exists and is NOT a symlink
while IFS= read -r target_raw; do
  target_expanded="${target_raw/#\\~/$HOME}"
  if [ -e "$target_expanded" ] && [ ! -L "$target_expanded" ]; then
    echo "❌ ERROR: Target '$target_expanded' (defined for '$target_raw' in $CONFIG_FILE) exists but is not a symlink."
    abort=true
  fi
done <<< "$targets_raw"

if [ "$abort" = true ]; then
  echo "⚠️ Aborting dotbot execution to prevent overwriting non-symlink files."
  echo "   Please manually back up or remove the conflicting file(s) listed above and run again."
  exit 1
fi

echo "✅ Pre-checks passed. No regular files will be overwritten."

echo "🧹 Removing existing managed symlinks before running Dotbot..."
removed_count=0
# Pre-remove any existing symlinks managed by this config
while IFS= read -r target_raw; do
  target_expanded="${target_raw/#~/$HOME}"
  # Check if it exists AND is a symlink
  if [ -L "$target_expanded" ]; then
      echo "   Symlink found: '$target_expanded'. Removing..."
      rm "$target_expanded"
      # Add a confirmation log AFTER removing:
      if [ ! -e "$target_expanded" ]; then
        echo "   Successfully removed '$target_expanded'."
      else
        echo "   ⚠️ WARNING: Failed to remove '$target_expanded'."
      fi
      ((removed_count++))
  fi
done <<< "$targets_raw"
if [ "$removed_count" -eq 0 ]; then
  echo "   No existing symlinks found to remove."
fi

echo "🔗 Running Dotbot in verbose mode to link files based on $CONFIG_FILE..."
git submodule update --init --recursive
./dotbot/bin/dotbot -v -c "$CONFIG_FILE"

echo "✅ Dotbot linking complete."