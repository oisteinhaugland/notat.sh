# Intended for zsh
# Daily Note Functions

note_daily_path() {
    local filename=$(date +"$NOTES_DAILY_DATE_FORMAT.md")
    echo "$NOTES_DAILY_DIR/$filename"
}

note_daily_content() {
    local date_str=$(date +"$NOTES_DAILY_DATE_FORMAT")
    echo "# $date_str"
}

note_daily_create() {
    note_create_or_open "$(note_daily_path)" "$(note_daily_content)"
}

note_daily_search() { note_search "$NOTES_DAILY_DIR"; }
note_daily_find()   { note_find "$NOTES_DAILY_DIR"; }
note_daily_review() { note_review "$NOTES_DAILY_DIR"; }
note_daily_open_today() { note_daily_create; }
