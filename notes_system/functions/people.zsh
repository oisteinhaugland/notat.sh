# Intended for zsh
# People Note Functions (Contacts/CRM)

note_people_path() {
    local name="$1"
    local safe_name=$(note_sanitize "$name")
    echo "$NOTES_PEOPLE_DIR/${safe_name}.md"
}

note_people_content() {
    local name="$1"
    echo "# $name"
}

note_people_create() {
    note_generic_create "people" "$1"
}

note_people_search() { note_search "$NOTES_PEOPLE_DIR"; }
note_people_pick()   { note_pick "$NOTES_PEOPLE_DIR"; }
note_people_review() { note_review_file "$NOTES_PEOPLE_DIR"; }
