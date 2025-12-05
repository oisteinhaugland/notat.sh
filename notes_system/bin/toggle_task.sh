#!/bin/bash
# Helper script to toggle task status
# Usage: toggle_task.sh "File:Line"

file_line="$1"

if [[ -z "$file_line" ]]; then
    exit 0
fi

# Extract file and line
if [[ "$file_line" == *:* ]]; then
    file="${file_line%:*}"
    line="${file_line##*:}"
else
    # If no line number, we can't toggle specific line
    exit 1
fi

if [[ ! -f "$file" ]]; then
    exit 1
fi

# Get the line content
content=$(sed -n "${line}p" "$file")

# Determine new marker
# Logic:
# . -> x
# = -> x
# > -> .
# x -> .
# ? -> .
# [space] -> . (if it looks like a task indent)

# We use awk to extract the first non-whitespace character
marker=$(echo "$content" | awk '{print substr($1, 1, 1)}')

new_marker=""

case "$marker" in
    '.') new_marker='x' ;;
    '=') new_marker='x' ;;
    '>') new_marker='.' ;;
    'x') new_marker='.' ;;
    '?') new_marker='.' ;;
    ',') new_marker='.' ;; # Parked -> Open
    *) 
        # Check if it's an indented task (starts with space)
        if [[ "$content" =~ ^[[:space:]]+ ]]; then
             # If it's indented but has no known marker, maybe we shouldn't touch it?
             # Or if the user wants to turn a plain line into a task?
             # For now, let's stick to toggling existing markers.
             exit 0
        fi
        exit 0 
        ;;
esac

if [[ -n "$new_marker" ]]; then
    # Replace the marker
    # We need to be careful to only replace the first occurrence of the marker on that line
    # and preserve indentation.
    
    # Escape marker for sed if needed (though . = > x ? , are mostly safe, . needs escape in regex but here we use substitution)
    # We want to replace the first non-whitespace char.
    
    # Use sed with a pattern that matches leading whitespace, then the marker
    # s/^(\s*)MARKER/\1NEW_MARKER/
    
    # Escape special chars for sed regex
    escaped_marker=$(echo "$marker" | sed 's/[.[\*^$]/\\&/g')
    
    sed -i "${line}s/^\([[:space:]]*\)$escaped_marker/\1$new_marker/" "$file"
fi
