# Intended for zsh
# Journal Note Functions (Topic Logs)

note_journal_path() {
    local title="$1"
    local safe_title=$(note_sanitize "$title")
    echo "$NOTES_JOURNALS_DIR/${safe_title}.md"
}

note_journal_content() {
    local title="$1"
    echo "# Journal: $title"
}

note_journal_create() {
    note_generic_create "journal" "$1"
}

note_journal_search() { note_search "$NOTES_JOURNALS_DIR"; }
note_journal_pick()   { note_pick "$NOTES_JOURNALS_DIR"; }
note_journal_review() { note_review_file "$NOTES_JOURNALS_DIR"; }
