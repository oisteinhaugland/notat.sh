# Intended for zsh
# Environment Management for Notat.sh

# List available environments
# Looks for directories inside ~/notes/
note_env_list() {
    echo "Available Environments:"
    echo "-----------------------"
    
    local base="$HOME/notes"
    
    # Ensure base exists
    mkdir -p "$base"
    
    # Check for subdirectories
    for dir in "$base"/*; do
        if [[ -d "$dir" ]]; then
            local name=$(basename "$dir")
            if [[ "$(note_env_current)" == "$name" ]]; then
                echo "* $name ($dir)"
            else
                echo "  $name ($dir)"
            fi
        fi
    done
}

# Get current environment name
note_env_current() {
    local state_file="$HOME/.config/notat/state"
    if [[ -f "$state_file" ]]; then
        cat "$state_file"
    else
        echo "personal"
    fi
}

# Switch environment
note_env_switch() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        echo "Usage: notat env switch <name>"
        return 1
    fi
    
    local target_dir="$HOME/notes/$name"
    
    # Check if directory exists, if not ask to create
    if [[ ! -d "$target_dir" ]]; then
        echo "Environment '$name' does not exist at $target_dir"
        echo -n "Create it? [y/N] "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            mkdir -p "$target_dir"
            echo "Created $target_dir"
        else
            return 1
        fi
    fi
    
    # Update state
    mkdir -p "$HOME/.config/notat"
    echo "$name" > "$HOME/.config/notat/state"
    
    echo "Switched to environment: $name"
}

# Help for env commands
note_env_help() {
    cat <<EOF
Usage: notat env <command>

Commands:
  list              List all available environments
  switch <name>     Switch to environment <name>

Examples:
  notat env list
  notat env switch work
  notat env switch personal
EOF
}
