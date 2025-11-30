# Intended for zsh
# People Note Functions (Contacts/CRM)

note_people_sanitize_name() {
    local name="$1"
    echo "$name" | tr ' ' '_' | tr -cd '[:alnum:]_-'
}

note_people_path() {
    local name="$1"
    local safe_name=$(note_people_sanitize_name "$name")
    echo "$NOTES_PEOPLE_DIR/${safe_name}.md"
}

note_people_content() {
    local name="$1"
    echo "# $name"
}

note_people_create() {
    local name=""
    
    if [[ -n "$1" ]]; then
        name="$1"
    elif [[ ! -t 0 ]]; then
        read name
    else
        echo -n "Enter person's name: "
        read name
    fi
    
    if [[ -z "$name" ]]; then
        echo "Error: Name cannot be empty."
        return 1
    fi

    note_create_or_open "$(note_people_path "$name")" "$(note_people_content "$name")"
}

note_people_search() { note_search "$NOTES_PEOPLE_DIR"; }
note_people_find()   { note_find "$NOTES_PEOPLE_DIR"; }
note_people_review() { note_review "$NOTES_PEOPLE_DIR"; }
