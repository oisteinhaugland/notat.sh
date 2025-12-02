# Intended for zsh
# Aliases for Notetaking System

# Search
alias sd='note_daily_search'
alias st='note_thought_search'

# Action Search Aliases
# sa: Search active top-level actions (Open ., Active =, Waiting >, Question ?)
# We use ^ to anchor to start of line.
# We exclude lines starting with whitespace (handled by saa)
# We need to be careful with > because it's also used for blockquotes/source links.
# Assuming actions are like "> Waiting", we match that.
alias sa='note_search_pattern "^[.=>?]"'

# saa: Search ALL active actions (including indented)
alias saa='note_search_pattern "^(\s*)[.=>?]"'

# sab: Search backlog/parked actions (,)
alias sab='note_search_pattern "^,"'

alias sj='note_journal_search'
alias sp='note_people_search'
alias sr='note_resource_search'

# Search Actions (Inline - Default)
alias sa='note_search "$NOTES_BASE_DIR" "^[.=>?,]"'
alias saa='note_search "$NOTES_BASE_DIR" "^\s*[.=>?,]"' # Same as sa but allows indentation
alias sab='note_search "$NOTES_BASE_DIR" "^,"'       # Backlog
alias saq='note_search "$NOTES_BASE_DIR" "^\?"'      # Questions

# Search Action Notes (Files)
alias san='note_action_note_search'

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
alias pa='note_action_pick' # Action Notes

# Review (Looped)
alias rd='note_daily_review'
alias rt='note_thought_review'
alias rj='note_journal_review'
alias rp='note_people_review'
alias rr='note_resource_review'

# Review Actions (Inline - Default)
alias ra='note_action_review'

# Review Action Notes (Files)
alias ran='note_action_note_review'

# New
alias nd='note_daily_create'
alias na='note_action_create'
alias nt='note_thought_create'

# Open
alias od='note_daily_open_today'
alias oa='note_action_open_active'
