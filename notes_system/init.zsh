# Intended for zsh or bash
# Entry point for the Notetaking System

# Detect script directory (Cross-shell compatible)
if [ -n "$BASH_VERSION" ]; then
    NOTES_SYSTEM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
elif [ -n "$ZSH_VERSION" ]; then
    NOTES_SYSTEM_DIR="${0:a:h}"
else
    # Fallback for other shells (may not work if sourced)
    NOTES_SYSTEM_DIR="$( cd "$( dirname "$0" )" && pwd )"
fi

# Source Configuration
source "$NOTES_SYSTEM_DIR/config.zsh"

# Source Functions
for func_file in "$NOTES_SYSTEM_DIR/functions/"*.zsh; do
    source "$func_file"
done

# Source Aliases
source "$NOTES_SYSTEM_DIR/aliases.zsh"
