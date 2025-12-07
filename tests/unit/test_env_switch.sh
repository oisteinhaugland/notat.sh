#!/bin/bash
set -e

# Setup test environment
TEST_DIR=$(mktemp -d)
export NOTES_BASE_DIR="$TEST_DIR/notes/personal"
export HOME="$TEST_DIR"
CONFIG_DIR="$TEST_DIR/.config/notat"
mkdir -p "$CONFIG_DIR"

echo "Using test dir: $TEST_DIR"

# Source modules
source ./notes_system/functions/env.zsh
source ./notes_system/config.zsh

# Test 1: Default Environment
echo "Testing Default Environment..."
CURRENT=$(note_env_current)
if [[ "$CURRENT" != "personal" ]]; then
    echo "FAIL: Expected 'personal', got '$CURRENT'"
    exit 1
fi
if [[ "$NOTES_BASE_DIR" != "$TEST_DIR/notes/personal" ]]; then
    echo "FAIL: Expected base dir '$TEST_DIR/notes/personal', got '$NOTES_BASE_DIR'"
    exit 1
fi

# Test 2: Switch to 'work'
echo "Testing Switch to 'work'..."
# Mock user input 'y' for directory creation
echo "y" | note_env_switch "work"

CURRENT=$(note_env_current)
if [[ "$CURRENT" != "work" ]]; then
    echo "FAIL: Expected 'work', got '$CURRENT'"
    exit 1
fi

# Simulate shell reload by re-sourcing config
unset NOTES_BASE_DIR
source ./notes_system/config.zsh

if [[ "$NOTES_BASE_DIR" != "$TEST_DIR/notes/work" ]]; then
    echo "FAIL: Expected base dir '$TEST_DIR/notes/work', got '$NOTES_BASE_DIR'"
    exit 1
fi

echo "✅ Environment Switching Verified!"
rm -rf "$TEST_DIR"
