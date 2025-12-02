#!/bin/bash
# setup_nvim.sh
# Helper script to set up Neovim integration for Notat.sh

set -euo pipefail

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="$HOME/.config/nvim"
LUA_DIR="$NVIM_CONFIG_DIR/lua"
TARGET_LINK="$LUA_DIR/notat.lua"
CONFIG_FILE="$LUA_DIR/notat_config.lua"
SOURCE_FILE="$SCRIPT_DIR/nvim_integration.lua"
INIT_LUA="$NVIM_CONFIG_DIR/init.lua"

echo "Setting up Neovim integration..."

# Ensure lua directory exists
if [ ! -d "$LUA_DIR" ]; then
    echo "Creating lua directory: $LUA_DIR"
    mkdir -p "$LUA_DIR"
fi

# Create Symlink
if [ -L "$TARGET_LINK" ]; then
    if [ "$(readlink "$TARGET_LINK")" == "$SOURCE_FILE" ]; then
        echo "Link already correct: $TARGET_LINK"
    else
        echo "Updating link: $TARGET_LINK"
        rm "$TARGET_LINK"
        ln -s "$SOURCE_FILE" "$TARGET_LINK"
    fi
elif [ -e "$TARGET_LINK" ]; then
    echo "Warning: File exists at $TARGET_LINK but is not a link. Please check manually."
else
    echo "Creating symlink: $TARGET_LINK -> $SOURCE_FILE"
    ln -s "$SOURCE_FILE" "$TARGET_LINK"
fi

# Create separate config file
echo "Creating config file: $CONFIG_FILE"
cat > "$CONFIG_FILE" <<EOF
-- Notat.sh Configuration
local ok, notat = pcall(require, 'notat')
if ok then
    notat.setup({
        notes_dir = os.getenv('NOTES_BASE_DIR'),
        actions_dir = os.getenv('NOTES_ACTIONS_DIR'),
    })
else
    vim.notify("Notat.sh: Could not load 'notat' module.", vim.log.levels.WARN)
end
EOF

# Update init.lua
REQUIRE_LINE="require('notat_config')"

if [ ! -f "$INIT_LUA" ]; then
    echo "Creating $INIT_LUA"
    echo "$REQUIRE_LINE" > "$INIT_LUA"
    echo "Created init.lua with Notat configuration."
else
    if grep -Fq "$REQUIRE_LINE" "$INIT_LUA"; then
        echo "Config already present in $INIT_LUA"
    else
        echo "Appending config to $INIT_LUA"
        echo "$REQUIRE_LINE" >> "$INIT_LUA"
    fi
fi

echo "Neovim setup complete."

if [ -f "$NVIM_CONFIG_DIR/init.vim" ]; then
    echo ""
    echo "WARNING: Found $NVIM_CONFIG_DIR/init.vim"
    echo "Neovim may ignore init.lua if init.vim is present."
    echo "Please ensure you are loading lua config from your init.vim."
fi

echo ""
echo "Please restart Neovim to apply changes."
echo "Note: Default hotkeys use <leader>. If you haven't set mapleader,"
echo "it defaults to backslash (\). Example: \o for smart open."

