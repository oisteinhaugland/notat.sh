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
alias sa='rg --smart-case "^[.=>?]" "$NOTES_BASE_DIR"'

# saa: Search ALL active actions (including indented)
alias saa='rg --smart-case "^(\s*)[.=>?]" "$NOTES_BASE_DIR"'

# sab: Search backlog/parked actions (,)
alias sab='rg --smart-case "^," "$NOTES_BASE_DIR"'

# sq: Search Questions (?)
alias sq='rg --smart-case "^\?" "$NOTES_BASE_DIR"'

# saf: Search action FILES (filenames in actions dir)
alias saf='note_action_search'

# Journal Aliases
alias nj='note_journal_create'
alias sj='note_journal_search'
alias fj='note_journal_find'
alias rj='note_journal_review'

# People Aliases
alias np='note_people_create'
alias sp='note_people_search'
alias fp='note_people_find'
alias rp='note_people_review'

# Resource Aliases
alias nr='note_resource_create'
alias sr='note_resource_search'
alias fr='note_resource_find'
alias rr='note_resource_review'

# Review
alias rd='note_daily_review'
alias ra='note_action_review'
alias rt='note_thought_review'

# Find
alias fd='note_daily_find'
alias fa='note_action_find'
alias ft='note_thought_find'

# New
alias nd='note_daily_create'
alias na='note_action_create'
alias nt='note_thought_create'

# Open
alias od='note_daily_open_today'
alias oa='note_action_open_active'
