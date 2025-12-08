# Intended for zsh
# Aliases for Notetaking System

# Wrapper function for notat command
# This is needed to handle 'env switch' in the current shell (not subprocess)
notat() {
    # Special case: env switch needs to run in current shell
    if [[ "$1" == "env" && "$2" == "switch" ]]; then
        local env_name="$3"
        if [[ -z "$env_name" ]]; then
            echo "Usage: notat env switch <name>"
            return 1
        fi
        
        # Call the function directly in current shell
        note_env_switch "$env_name" && source "$NOTES_SYSTEM_DIR/config.zsh"
        return $?
    fi
    
    # For all other commands, call the notat binary
    command notat "$@"
}

# Short alias for environment switching
alias ne='notat env switch'

# Search
alias sd='note_daily_search'
alias st='note_thought_search'

# Action Search Aliases
# sa: Search active top-level actions (Open ., Active =, Waiting >, Question ?)
# We use ^ to anchor to start of line.
# We exclude lines starting with whitespace (handled by saa)
# We need to be careful with > because it's also used for blockquotes/source links.
# Assuming actions are like "> Waiting", we match that.
alias sa='note_search_pattern "^[.=>?]" "$NOTES_BASE_DIR"'

# saa: Search ALL active actions (including indented)
alias saa='note_search_pattern "^(\s*)[.=>?]" "$NOTES_BASE_DIR"'

# sab: Search backlog/parked actions (,)
alias sab='note_search_pattern "^," "$NOTES_BASE_DIR"'

# saab: Search all backlog/parked actions (including indented)
alias saab='note_search_pattern "^\s*," "$NOTES_BASE_DIR"'

alias sj='note_journal_search'
alias sp='note_people_search'
alias sr='note_resource_search'



# Search Action Notes (Files)
alias san='note_action_note_search'

# Archive Search (All types)
alias sA='note_search "$NOTES_ARCHIVE_DIR"'

# Archive Search by Type
alias stA='note_search "$NOTES_ARCHIVE_DIR/thoughts"'
alias saA='note_search "$NOTES_ARCHIVE_DIR/actions"'
alias sdA='note_search "$NOTES_ARCHIVE_DIR/daily"'
alias sjA='note_search "$NOTES_ARCHIVE_DIR/journals"'

# Journal Aliases
# The individual search aliases are now part of the general search block above.
# alias sj='note_journal_search' # Moved
alias nj='note_journal_create'
alias pj='note_journal_pick'
alias rj='note_journal_review'

# People Aliases
# alias sp='note_people_search' # Moved
alias np='note_people_create'
alias pp='note_people_pick'
alias rp='note_people_review'

# Resource Aliases
# alias sr='note_resource_search' # Moved
alias nr='note_resource_create'
alias pr='note_resource_pick'
alias rr='note_resource_review'

# Pick (Single-shot File)
alias pd='note_daily_pick'
alias pt='note_thought_pick'
alias pj='note_journal_pick'
alias pp='note_people_pick'
alias pr='note_resource_pick'
alias pan='note_action_pick' # Pick Action Note (file)

# Review (Looped)
alias rd='note_daily_review'
alias rt='note_thought_review'
alias rj='note_journal_review'
alias rp='note_people_review'
alias rr='note_resource_review'

# Review Actions (Inline - Default)
alias ra='note_action_review'
alias raa='note_action_review_all'

# Review Action Backlog (Inline)
alias rab='note_action_backlog_review'
alias raab='note_action_backlog_review_all'

# Review Action Notes (Files)
alias ran='note_action_note_review'

# Archive Review (All types)
alias rA='note_review_file "$NOTES_ARCHIVE_DIR"'

# Archive Review by Type
alias rtA='note_review_file "$NOTES_ARCHIVE_DIR/thoughts"'
alias raA='note_review_file "$NOTES_ARCHIVE_DIR/actions"'
alias rdA='note_review_file "$NOTES_ARCHIVE_DIR/daily"'
alias rjA='note_review_file "$NOTES_ARCHIVE_DIR/journals"'

# New
alias nd='note_daily_create'
alias na='note_action_create'
alias nt='note_thought_create'

# Open
alias od='note_daily_open_today'
alias oa='note_action_open_active'
alias ob='note_dashboard_open'

# Maintenance
# notat command is handled by bin/notat in PATH

