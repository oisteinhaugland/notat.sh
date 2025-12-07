#!/bin/zsh

# Setup environment
export NOTES_BASE_DIR="./test_notes_dir"
export NOTES_ACTIONS_DIR="$NOTES_BASE_DIR/actions"
mkdir -p "$NOTES_ACTIONS_DIR"

# Source functions
source ./notes_system/config.zsh
source ./notes_system/functions/core.zsh
source ./notes_system/functions/action.zsh

# Mock editor to avoid interactive mode
note_open_editor() {
    echo "MOCK EDITOR: Opening $1"
    if [[ -f "$1" ]]; then
        echo "File content:"
        cat "$1"
    else
        echo "File does not exist!"
    fi
}

echo "--- Test 1: Normal Action ---"
note_action_create "Buy Milk"

echo "--- Test 2: Symbol Only Action (Bug Reproduction) ---"
note_action_create "."

echo "--- Test 3: Empty Action ---"
note_action_create ""

# Clean up
rm -rf "$NOTES_BASE_DIR"
