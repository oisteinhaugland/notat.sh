# Intended for zsh
# Action Note Functions

note_action_sanitize_title() {
    local title="$1"
    # Strip leading action symbols and whitespace
    # Symbols: . , = x > ?
    local clean_title=$(echo "$title" | sed 's/^[.,=x>?][[:space:]]*//')
    echo "$clean_title" | tr ' ' '_' | tr -cd '[:alnum:]_-'
}

note_action_path() {
    local title="$1"
    local safe_title=$(note_action_sanitize_title "$title")
    echo "$NOTES_ACTIONS_DIR/${safe_title}.md"
}

note_action_content() {
    local title="$1"
    local source="$2"
    
    # Strip symbols for the header too, to look nice
    local clean_title=$(echo "$title" | sed 's/^[.,=x>?][[:space:]]*//')
    
    echo "# ACTION: $clean_title"
    if [[ -n "$source" ]]; then
        echo "@ Source: $source"
    fi
}

note_action_create_with_title() {
    local title="$1"
    local source="$2"
    note_create_or_open "$(note_action_path "$title")" "$(note_action_content "$title" "$source")"
}

note_action_create() {
    local title=""
    local source=""
    
    if [[ -n "$1" ]]; then
        title="$1"
        source="$2"
    elif [[ ! -t 0 ]]; then
        read title
    else
        echo -n "Enter action title: "
        read title
    fi
    
    # Sanitize first to check if it results in empty string
    local safe_title=$(note_action_sanitize_title "$title")
    
    if [[ -z "$safe_title" ]]; then
        # If title was just symbols or empty, prompt again or error
        echo "Error: Title cannot be empty or just symbols."
        echo -n "Enter valid action title: "
        read title
        safe_title=$(note_action_sanitize_title "$title")
        
        if [[ -z "$safe_title" ]]; then
             echo "Error: Invalid title."
             return 1
        fi
    fi

    note_action_create_with_title "$title" "$source"
}

# Inline Actions (The default "Action")
note_action_search() { 
    # Search for lines starting with action symbols
    note_search "$NOTES_BASE_DIR" "^[.=>?,]" 
}

note_action_review() { 
    # Review lines starting with action symbols (Looped)
    note_review_inline "$NOTES_BASE_DIR" "^[.=>?,]" 
}

# Action Notes (The files in actions/)
note_action_pick() { 
    note_pick "$NOTES_ACTIONS_DIR" 
}

note_action_note_search() { 
    note_search "$NOTES_ACTIONS_DIR" 
}

note_action_note_review() { 
    note_review_file "$NOTES_ACTIONS_DIR" 
}

note_action_open_active() {
    # Find first active task (=) and open it
    local active
    active=$(rg --line-number --no-heading --color=never "^= " "$NOTES_BASE_DIR" | head -n 1)
    
    if [[ -n "$active" ]]; then
        local file=$(echo "$active" | cut -d: -f1)
        local line=$(echo "$active" | cut -d: -f2)
        note_open_editor "$file" "$line"
    else
        echo "No active tasks found."
    fi
}
