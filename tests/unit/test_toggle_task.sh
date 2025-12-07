#!/bin/bash
# Test script for toggle_task.sh

# Setup
TEST_FILE="./test_toggle.md"
TOGGLE_SCRIPT="./notes_system/bin/toggle_task.sh"

# Helper to assert line content
assert_line() {
    local line_num="$1"
    local expected="$2"
    local actual=$(sed -n "${line_num}p" "$TEST_FILE")
    
    if [[ "$actual" == "$expected" ]]; then
        echo "PASS: Line $line_num is '$expected'"
    else
        echo "FAIL: Line $line_num expected '$expected', got '$actual'"
        exit 1
    fi
}

# Create test file
cat <<EOF > "$TEST_FILE"
. Open Task
= Active Task
> Waiting Task
x Done Task
? Question Task
, Parked Task
  . Indented Open
  x Indented Done
EOF

echo "--- Testing Toggle Logic ---"

# 1. Toggle Open (.) -> Done (x)
echo "Toggling Open Task (Line 1)..."
$TOGGLE_SCRIPT "$TEST_FILE:1"
assert_line 1 "x Open Task"

# 2. Toggle Active (=) -> Done (x)
echo "Toggling Active Task (Line 2)..."
$TOGGLE_SCRIPT "$TEST_FILE:2"
assert_line 2 "x Active Task"

# 3. Toggle Waiting (>) -> Open (.)
echo "Toggling Waiting Task (Line 3)..."
$TOGGLE_SCRIPT "$TEST_FILE:3"
assert_line 3 ". Waiting Task"

# 4. Toggle Done (x) -> Open (.)
echo "Toggling Done Task (Line 4)..."
$TOGGLE_SCRIPT "$TEST_FILE:4"
assert_line 4 ". Done Task"

# 5. Toggle Question (?) -> Open (.)
echo "Toggling Question Task (Line 5)..."
$TOGGLE_SCRIPT "$TEST_FILE:5"
assert_line 5 ". Question Task"

# 6. Toggle Parked (,) -> Open (.)
echo "Toggling Parked Task (Line 6)..."
$TOGGLE_SCRIPT "$TEST_FILE:6"
assert_line 6 ". Parked Task"

# 7. Toggle Indented Open (.) -> Done (x)
echo "Toggling Indented Open (Line 7)..."
$TOGGLE_SCRIPT "$TEST_FILE:7"
assert_line 7 "  x Indented Open"

# 8. Toggle Indented Done (x) -> Open (.)
echo "Toggling Indented Done (Line 8)..."
$TOGGLE_SCRIPT "$TEST_FILE:8"
assert_line 8 "  . Indented Done"

echo "--- All Toggle Tests Passed ---"

# Cleanup
rm "$TEST_FILE"
