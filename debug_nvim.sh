#!/bin/bash
# debug_nvim.sh

export NOTES_BASE_DIR="/tmp/notes"
export NOTES_ACTIONS_DIR="/tmp/notes/actions"
mkdir -p "$NOTES_ACTIONS_DIR"

# Create a minimal init.lua for testing
cat > /tmp/test_init.lua <<EOF
vim.g.mapleader = " " -- Set leader to space for testing
package.path = package.path .. ";$HOME/.config/nvim/lua/?.lua"

local ok, notat = pcall(require, 'notat')
if not ok then
    print("Error loading notat: " .. notat)
    os.exit(1)
end

notat.setup({
    notes_dir = "$NOTES_BASE_DIR",
    actions_dir = "$NOTES_ACTIONS_DIR",
})

-- Check if keymaps are set
local keymaps = vim.api.nvim_get_keymap('n')
local found = false
for _, map in ipairs(keymaps) do
    if map.lhs == " o" then -- <leader>o with space leader
        print("Found keymap: <leader>o -> " .. tostring(map.rhs or map.callback))
        found = true
    end
end

if found then
    print("Success: Keymaps are set.")
else
    print("Failure: Keymaps not found.")
    os.exit(1)
end
EOF

# Run nvim headless
nvim --headless -u /tmp/test_init.lua -c "q"
