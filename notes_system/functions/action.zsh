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
    
    if [[ -z "$title" ]]; then
        echo "Error: Title cannot be empty."
        return 1
    fi

    note_action_create_with_title "$title" "$source"
}

note_action_search() { note_search "$NOTES_ACTIONS_DIR"; }
note_action_find()   { note_find "$NOTES_ACTIONS_DIR"; }
note_action_review() { note_review "$NOTES_ACTIONS_DIR"; }

note_action_open_active() {
    if ! command -v rg &> /dev/null; then
        echo "Error: rg (ripgrep) is not installed."
        return 1
    fi

    # Find the first line starting with "= "
    local match=$(rg --line-number --no-heading --color=never --smart-case "^= " "$NOTES_BASE_DIR" | head -n 1)
    
    if [[ -n "$match" ]]; then
        local file=$(echo "$match" | cut -d: -f1)
        local line=$(echo "$match" | cut -d: -f2)
        echo "Opening active task: $file:$line"
        "$EDITOR" "+$line" "$file"
    else
        echo "No active task found."
        return 1
    fi
}
