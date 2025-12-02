# Intended for zsh
# Thought Note Functions

note_thought_path() {
    local timestamp=$(date +%Y-%m-%d-%H:%M:%S)
    local filename="${timestamp}.md"
    echo "$NOTES_THOUGHTS_DIR/$filename"
}

note_thought_content() {
    echo "# "
}

note_thought_create() {
    note_create_or_open "$(note_thought_path)" "$(note_thought_content)"
}

note_thought_search() { note_search "$NOTES_THOUGHTS_DIR"; }
note_thought_pick()   { note_pick "$NOTES_THOUGHTS_DIR"; }
note_thought_review() { note_review_file "$NOTES_THOUGHTS_DIR"; }
