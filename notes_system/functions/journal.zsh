# Intended for zsh
# Journal Note Functions (Topic Logs)

note_journal_sanitize_title() {
    local title="$1"
    echo "$title" | tr ' ' '_' | tr -cd '[:alnum:]_-'
}

note_journal_path() {
    local title="$1"
    local safe_title=$(note_journal_sanitize_title "$title")
    echo "$NOTES_JOURNALS_DIR/${safe_title}.md"
}

note_journal_content() {
    local title="$1"
    echo "# Journal: $title"
}

note_journal_create() {
    local title=""
    
    if [[ -n "$1" ]]; then
        title="$1"
    elif [[ ! -t 0 ]]; then
        read title
    else
        echo -n "Enter journal topic: "
        read title
    fi
    
    if [[ -z "$title" ]]; then
        echo "Error: Topic cannot be empty."
        return 1
    fi

    note_create_or_open "$(note_journal_path "$title")" "$(note_journal_content "$title")"
}

note_journal_search() { note_search "$NOTES_JOURNALS_DIR"; }
note_journal_find()   { note_pick "$NOTES_JOURNALS_DIR"; }
note_journal_review() { note_review "$NOTES_JOURNALS_DIR"; }
