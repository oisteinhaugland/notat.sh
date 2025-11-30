# Intended for zsh
# Resource Note Functions (Static Knowledge/Reference)

note_resource_sanitize_title() {
    local title="$1"
    echo "$title" | tr ' ' '_' | tr -cd '[:alnum:]_-'
}

note_resource_path() {
    local title="$1"
    local safe_title=$(note_resource_sanitize_title "$title")
    echo "$NOTES_RESOURCES_DIR/${safe_title}.md"
}

note_resource_content() {
    local title="$1"
    echo "# Resource: $title"
}

note_resource_create() {
    local title=""
    
    if [[ -n "$1" ]]; then
        title="$1"
    elif [[ ! -t 0 ]]; then
        read title
    else
        echo -n "Enter resource title: "
        read title
    fi
    
    if [[ -z "$title" ]]; then
        echo "Error: Title cannot be empty."
        return 1
    fi

    note_create_or_open "$(note_resource_path "$title")" "$(note_resource_content "$title")"
}

note_resource_search() { note_search "$NOTES_RESOURCES_DIR"; }
note_resource_find()   { note_find "$NOTES_RESOURCES_DIR"; }
note_resource_review() { note_review "$NOTES_RESOURCES_DIR"; }
