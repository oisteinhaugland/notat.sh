#!/bin/bash
# Helper script to open files from fzf
# Usage: opener.sh "File:Line" [editor_cmd]

file_line="$1"
editor_cmd="${2:-${EDITOR:-vim}}"

if [[ -z "$file_line" ]]; then
    exit 0
fi

# Extract file and line
# Expected format: "path/to/file:line" or just "path/to/file"
if [[ "$file_line" == *:* ]]; then
    file="${file_line%:*}"
    line="${file_line##*:}"
else
    file="$file_line"
    line=""
fi

# Open editor
if [[ -n "$line" ]]; then
    "$editor_cmd" "+$line" "$file"
else
    "$editor_cmd" "$file"
fi
