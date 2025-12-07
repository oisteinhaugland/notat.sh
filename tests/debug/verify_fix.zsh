#!/bin/zsh

# Setup environment
export NOTES_BASE_DIR="./test_notes_dir_v2"
export NOTES_ACTIONS_DIR="$NOTES_BASE_DIR/actions"
mkdir -p "$NOTES_ACTIONS_DIR"

# Source functions
source ./notes_system/config.zsh
source ./notes_system/functions/core.zsh
source ./notes_system/functions/action.zsh

# Mock editor
note_open_editor() {
    echo "MOCK EDITOR: Opening $1"
}

echo "--- Test 1: Normal Action ---"
note_action_create "Buy Milk"

echo "--- Test 2: Symbol Only Action (Should Error/Prompt) ---"
# We pipe "New Title" into it to simulate the prompt response
echo "New Title" | note_action_create "."

echo "--- Test 3: Empty Action (Should Error/Prompt) ---"
echo "Another Title" | note_action_create ""

# Clean up
rm -rf "$NOTES_BASE_DIR"
