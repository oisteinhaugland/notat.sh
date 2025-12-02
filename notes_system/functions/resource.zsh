# Intended for zsh
# Resource Note Functions (Static Knowledge/Reference)

note_resource_path() {
    local title="$1"
    local safe_title=$(note_sanitize "$title")
    echo "$NOTES_RESOURCES_DIR/${safe_title}.md"
}

note_resource_content() {
    local title="$1"
    echo "# Resource: $title"
}

note_resource_create() {
    note_generic_create "resource" "$1"
}

note_resource_search() { note_search "$NOTES_RESOURCES_DIR"; }
note_resource_pick()   { note_pick "$NOTES_RESOURCES_DIR"; }
note_resource_review() { note_review_file "$NOTES_RESOURCES_DIR"; }
