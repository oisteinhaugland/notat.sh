#!/bin/bash

# Setup test environment
shopt -s expand_aliases
export NOTES_BASE_DIR="./test_notes"
mock_editor() {
    echo "[EDITOR OPEN] $@"
}
export EDITOR=mock_editor
export NOTES_SYSTEM_DIR="./notes_system"

# Clean up previous run
rm -rf "$NOTES_BASE_DIR"

# Source the system
source ./notes_system/init.zsh

# --- Rigorous Testing ---

# Helper to assert file content
assert_content() {
    local file="$1"
    local expected="$2"
    if grep -Fq "$expected" "$file"; then
        echo "PASS: File $file contains '$expected'"
    else
        echo "FAIL: File $file does NOT contain '$expected'"
        exit 1
    fi
}

# Helper to assert exit code
assert_success() {
    if [ $? -eq 0 ]; then
        echo "PASS: Command succeeded"
    else
        echo "FAIL: Command failed"
        exit 1
    fi
}

echo "--- Testing Daily Note ---"
# Mock date to ensure consistency
export NOTES_DAILY_DATE_FORMAT="%Y-%m-%d"
today=$(date +"%Y-%m-%d")
expected_file="$NOTES_DAILY_DIR/$today.md"

# Run command
output=$(nd)
assert_success

if [[ -f "$expected_file" ]]; then
    echo "PASS: Daily note created at $expected_file"
    assert_content "$expected_file" "# $today"
else
    echo "FAIL: Daily note not found at $expected_file"
    exit 1
fi

echo "--- Testing Thought Note ---"
# Run command
output=$(nt)
assert_success

# Find the most recent thought note
latest_thought=$(ls -t "$NOTES_THOUGHTS_DIR" | head -n 1)
expected_thought="$NOTES_THOUGHTS_DIR/$latest_thought"

if [[ -f "$expected_thought" ]]; then
    echo "PASS: Thought note created: $latest_thought"
    # Check timestamp format in filename (YYYY-MM-DD-HH:MM:SS.md)
    if [[ "$latest_thought" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{2}:[0-9]{2}:[0-9]{2}\.md$ ]]; then
        echo "PASS: Filename format correct"
    else
        echo "FAIL: Filename format incorrect: $latest_thought"
        exit 1
    fi
    assert_content "$expected_thought" "# "
else
    echo "FAIL: No thought note found"
    exit 1
fi

echo "--- Testing Action Note ---"
# Test creating action note (na) with title argument
output=$(na "My Test Action")
assert_success
expected_file="$NOTES_ACTIONS_DIR/My_Test_Action.md"

if [[ -f "$expected_file" ]]; then
    echo "PASS: Action note created at $expected_file"
    assert_content "$expected_file" "# ACTION: My Test Action"
else
    echo "FAIL: Action note not found at $expected_file"
    exit 1
fi

echo "--- Testing Advanced Action Logic ---"
# Test symbol stripping and source linking
line=". Call Mom"
source="daily/2025-11-29.md:10"

output=$(note_action_create "$line" "$source")
assert_success
expected_action_file="$NOTES_ACTIONS_DIR/Call_Mom.md"

if [[ -f "$expected_action_file" ]]; then
    echo "PASS: Action note created from line"
    assert_content "$expected_action_file" "# ACTION: Call Mom"
    assert_content "$expected_action_file" "@ Source: $source"
else
    echo "FAIL: Action note from line not found at $expected_action_file"
    exit 1
fi

echo "--- Testing Search Aliases ---"
# Create dummy files
echo ". Open Task" > "$NOTES_BASE_DIR/test_open.md"
echo "= Active Task" > "$NOTES_BASE_DIR/test_active.md"
echo ", Parked Task" > "$NOTES_BASE_DIR/test_parked.md"
echo "? Question Task" > "$NOTES_BASE_DIR/test_question.md"
echo "  . Indented Task" > "$NOTES_BASE_DIR/test_indented.md"

echo "Testing sa (Active Top-level)..."
sa_out=$(sa)
# Should find Open, Active, and Question
if echo "$sa_out" | grep -q "Open Task" && echo "$sa_out" | grep -q "Active Task" && echo "$sa_out" | grep -q "Question Task"; then
    echo "PASS: sa finds active tasks and questions"
else
    echo "FAIL: sa missing active tasks or questions"
    exit 1
fi
# Should NOT find Parked or Indented
if echo "$sa_out" | grep -q "Parked Task"; then echo "FAIL: sa found Parked"; exit 1; fi
if echo "$sa_out" | grep -q "Indented Task"; then echo "FAIL: sa found Indented"; exit 1; fi

echo "Testing sab (Backlog)..."
sab_out=$(sab)
if echo "$sab_out" | grep -q "Parked Task"; then
    echo "PASS: sab finds parked tasks"
else
    echo "FAIL: sab missing parked tasks"
    exit 1
fi
if echo "$sab_out" | grep -q "Open Task"; then echo "FAIL: sab found Open"; exit 1; fi

echo "Testing sq (Questions)..."
sq_out=$(sq)
if echo "$sq_out" | grep -q "Question Task"; then
    echo "PASS: sq finds questions"
else
    echo "FAIL: sq missing questions"
    exit 1
fi
if echo "$sq_out" | grep -q "Open Task"; then echo "FAIL: sq found Open"; exit 1; fi

echo "Testing saa (All Active)..."
saa_out=$(saa)
if echo "$saa_out" | grep -q "Indented Task" && echo "$saa_out" | grep -q "Open Task" && echo "$saa_out" | grep -q "Question Task"; then
    echo "PASS: saa finds indented tasks and questions"
else
    echo "FAIL: saa missing indented tasks or questions"
    exit 1
fi

echo "--- Testing Journal Note ---"
output=$(nj "My Therapy Log")
assert_success
expected_file="$NOTES_JOURNALS_DIR/My_Therapy_Log.md"

if [[ -f "$expected_file" ]]; then
    echo "PASS: Journal created at $expected_file"
    assert_content "$expected_file" "# Journal: My Therapy Log"
else
    echo "FAIL: Journal not found at $expected_file"
    exit 1
fi

echo "--- Testing People Note ---"
output=$(np "Alice Smith")
assert_success
expected_file="$NOTES_PEOPLE_DIR/Alice_Smith.md"

if [[ -f "$expected_file" ]]; then
    echo "PASS: Person note created at $expected_file"
    assert_content "$expected_file" "# Alice Smith"
else
    echo "FAIL: Person note not found at $expected_file"
    exit 1
fi

echo "--- Testing Open Active (oa) ---"
# We have "test_active.md" with "= Active Task" created earlier
# oa uses EDITOR. We need to capture the output.
# Since we mocked EDITOR to just print args, we expect it to print "+1 ./test_notes/test_active.md"
# note_action_open_active also prints "Opening active task: ..."

output=$(oa)
assert_success

if echo "$output" | grep -q "Opening active task:"; then
    echo "PASS: oa found active task"
else
    echo "FAIL: oa did not find active task"
    exit 1
fi

echo "--- Testing Aliases ---"
for alias_name in sd sa st sab saf saa sq sj sp nj np oa; do
    if alias $alias_name >/dev/null; then
        echo "PASS: Alias $alias_name exists"
    else
        echo "FAIL: Alias $alias_name missing"
        exit 1
    fi
done

echo "--- Testing Find (fd) ---"
# Create a dummy file to find
touch "$NOTES_DAILY_DIR/find_me.md"
# We can't easily test the interactive fzf part, but we can check if the function runs without error
# and if we can mock fzf to return a file.
# For now, let's just check if the alias exists and points to note_find
if alias fd | grep -q "note_daily_find"; then
    echo "PASS: Alias fd points to note_daily_find"
else
    echo "FAIL: Alias fd incorrect"
    exit 1
fi


echo "--- Testing Archive Directory ---"
if [[ -d "$NOTES_ARCHIVE_DIR" ]]; then
    echo "PASS: Archive directory exists at $NOTES_ARCHIVE_DIR"
else
    echo "FAIL: Archive directory missing"
    exit 1
fi

echo "--- All Tests Passed ---"

# Clean up
rm -rf "$NOTES_BASE_DIR"
