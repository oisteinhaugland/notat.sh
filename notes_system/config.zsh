# Intended for zsh
# Configuration for Notetaking System

# Default base directory for notes
# Managed by 'notat env'
if [[ -f "$HOME/.config/notat/state" ]]; then
    ENV_NAME=$(cat "$HOME/.config/notat/state")
    if [[ "$ENV_NAME" == "default" ]]; then
        : ${NOTES_BASE_DIR:="$HOME/notes/personal"}
    else
        : ${NOTES_BASE_DIR:="$HOME/notes/$ENV_NAME"}
    fi
else
    # Fallback/First Run
    : ${NOTES_BASE_DIR:="$HOME/notes/personal"}
fi

# Subdirectories
export NOTES_DAILY_DIR="$NOTES_BASE_DIR/daily"
export NOTES_THOUGHTS_DIR="$NOTES_BASE_DIR/thoughts"
export NOTES_ACTIONS_DIR="$NOTES_BASE_DIR/actions"
export NOTES_JOURNALS_DIR="$NOTES_BASE_DIR/journals"
export NOTES_PEOPLE_DIR="$NOTES_BASE_DIR/people"
export NOTES_RESOURCES_DIR="$NOTES_BASE_DIR/resources"
export NOTES_ARCHIVE_DIR="$NOTES_BASE_DIR/archive"

# Ensure directories exist
mkdir -p "$NOTES_DAILY_DIR"
mkdir -p "$NOTES_THOUGHTS_DIR"
mkdir -p "$NOTES_ACTIONS_DIR"
mkdir -p "$NOTES_JOURNALS_DIR"
mkdir -p "$NOTES_PEOPLE_DIR"
mkdir -p "$NOTES_RESOURCES_DIR"
mkdir -p "$NOTES_ARCHIVE_DIR"

# Date format for daily notes
# Format: YYYY-MM-DD Month DD Day
# e.g. 2025-11-29 Nov 29 Saturday
export NOTES_DAILY_DATE_FORMAT="%Y-%m-%d %b %d %A"

# Editor Configuration
export EDITOR="${EDITOR:-vim}"

# FZF Configuration
# Common options for all FZF interactions
export NOTES_FZF_OPTS="--ansi --delimiter : --layout=reverse --border --height=80%"

# Bat Theme for Previews
# A high-contrast theme is recommended for better line highlighting
export NOTES_BAT_THEME="${NOTES_BAT_THEME:-Visual Studio Dark+}"

# FZF Preview Window Configuration
# Default to vertical split (right side)
export NOTES_FZF_PREVIEW_WINDOW="${NOTES_FZF_PREVIEW_WINDOW:-right,50%,border-left}"
