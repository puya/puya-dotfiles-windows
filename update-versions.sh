#!/bin/bash

# 🔄 Tool Versions Updater
# This script automatically updates your .tool-versions file to the latest stable releases.

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

TOOL_VERSIONS_FILE=".tool-versions"

if [ ! -f "$TOOL_VERSIONS_FILE" ]; then
  echo -e "${RED}❌ Error: .tool-versions file not found.${NC}"
  exit 1
fi

echo -e "${BLUE}🔄 Checking for updates for tools in $TOOL_VERSIONS_FILE...${NC}"

# Ensure asdf is available
if [ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]; then
    . "$(brew --prefix asdf)/libexec/asdf.sh"
else
    echo -e "${RED}❌ ASDF not found. Please install it first.${NC}"
    exit 1
fi


while read -r tool version || [[ -n "$tool" ]]; do
  if [[ -z "$tool" || "$tool" == \#* ]]; then
    continue # Skip empty or commented lines
  fi

  echo -e "\n${YELLOW}Checking '$tool'...${NC}"
  
  latest_version_output=""
  # Special handling for nodejs to get LTS
  if [ "$tool" == "nodejs" ]; then
    echo "  -> Finding latest LTS version..."
    latest_version_output=$(asdf latest nodejs lts 2>/dev/null)
  elif [ "$tool" == "python" ]; then
    echo "  -> Finding latest stable, non-experimental version..."
    # This filters out versions with suffixes like '-dev' or 't'
    latest_version_output=$(asdf list all python | grep -E '^[0-9\.]+$' | sort -V | tail -n 1)
  else
    echo "  -> Finding latest stable version..."
    latest_version_output=$(asdf latest "$tool" 2>/dev/null)
  fi

  # Validate the output from asdf latest. It should be a single token.
  # If it's empty or contains spaces (like in an error message), skip it.
  if [ -z "$latest_version_output" ] || [[ "$latest_version_output" =~ \s ]]; then
    echo -e "  ${YELLOW}Could not find a valid latest version for $tool. Skipping update check.${NC}"
    # Do not 'continue' here, let it fall through so the version is checked against itself
    # and no 'Found new version' message is printed.
    latest_version="$version" # Set to current to prevent update message
  else
    # The output is good, let's use it as the latest version
    latest_version=$latest_version_output
  fi

  if [ "$version" == "$latest_version" ]; then
    echo -e "  ${GREEN}You already have the latest version: $version${NC}"
  else
    echo -e "  ${GREEN}Found new version: $latest_version (current: $version)${NC}"
    # Use sed to update the version in-place
    # The empty extension '' after -i works for BSD sed (macOS) and GNU sed
    sed -i '' "s/^$tool .*/$tool $latest_version/" "$TOOL_VERSIONS_FILE"
    echo "  -> Updated $TOOL_VERSIONS_FILE"
  fi
done < <(grep -v '^#' "$TOOL_VERSIONS_FILE" | grep -v '^\s*$') # Process file safely

# Clean up backup file if it exists (some sed versions create it)
[[ -f "${TOOL_VERSIONS_FILE}.bak" ]] && rm -f "${TOOL_VERSIONS_FILE}.bak"
[[ -f "${TOOL_VERSIONS_FILE}''" ]] && rm -f "${TOOL_VERSIONS_FILE}''"

echo -e "\n${BLUE}✅ All tools checked. Run 'asdf install' to install the new versions.${NC}" 