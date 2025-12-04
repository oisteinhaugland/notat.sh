#!/bin/bash

# preview.sh
# Centralized preview logic for Notat.sh FZF integration.
# Usage: preview.sh <file_path>[:<line_number>]

INPUT="$1"

if [[ -z "$INPUT" ]]; then
    echo "Usage: preview.sh <file_path>[:<line_number>]"
    exit 1
fi

# 1. Parse Input
# Check if input has a colon followed by numbers at the end
if [[ "$INPUT" =~ :[0-9]+$ ]]; then
    FILE="${INPUT%:*}"
    LINE="${INPUT##*:}"
else
    FILE="$INPUT"
    LINE=""
fi

# 2. Resolve Path (Basic check)
if [[ ! -f "$FILE" ]]; then
    echo "File not found: $FILE"
    exit 0 # Exit gracefully so FZF doesn't show ugly errors
fi

# 3. Render
if command -v bat &> /dev/null; then
    # BAT is available
    if [[ -n "$LINE" ]]; then
        bat --style=numbers --color=always --highlight-line "$LINE" "$FILE"
    else
        bat --style=numbers --color=always "$FILE"
    fi
else
    # Fallback to cat/head/tail
    if [[ -n "$LINE" ]]; then
        # Show context around the line (e.g., 10 lines before and after)
        START=$((LINE - 10))
        if (( START < 1 )); then START=1; fi
        END=$((LINE + 10))
        
        # Use sed to print the range
        sed -n "${START},${END}p" "$FILE"
    else
        cat "$FILE"
    fi
fi
