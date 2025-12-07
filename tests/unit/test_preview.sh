#!/bin/bash

# test_preview.sh
# Test the preview.sh script

PREVIEW_SCRIPT="./notes_system/bin/preview.sh"
TEST_FILE="test_file.txt"

# Setup
echo "Creating test file..."
cat <<EOF > "$TEST_FILE"
Line 1
Line 2
Line 3
Line 4
Line 5
EOF

echo "--- Test 1: Basic File Preview ---"
"$PREVIEW_SCRIPT" "$TEST_FILE"
if [[ $? -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi

echo "--- Test 2: File with Line Number ---"
"$PREVIEW_SCRIPT" "$TEST_FILE:3"
if [[ $? -eq 0 ]]; then echo "PASS"; else echo "FAIL"; fi

echo "--- Test 3: Non-existent File ---"
"$PREVIEW_SCRIPT" "non_existent_file.txt"
if [[ $? -eq 0 ]]; then echo "PASS (Graceful exit)"; else echo "FAIL"; fi

echo "--- Test 4: Missing Argument ---"
"$PREVIEW_SCRIPT"
if [[ $? -eq 1 ]]; then echo "PASS"; else echo "FAIL"; fi

# Cleanup
rm "$TEST_FILE"
