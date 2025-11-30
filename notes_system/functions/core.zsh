# Intended for zsh
# Core functions for Notetaking System

note_file_exists() {
    local filepath="$1"
    [[ -f "$filepath" ]]
}

note_write_file() {
    local filepath="$1"
    local content="$2"
    
    mkdir -p "$(dirname "$filepath")"
    
    echo "$content" > "$filepath"
    echo "Created note: $filepath"
}

note_open_editor() {
    local filepath="$1"
    
    if [[ -z "$EDITOR" ]]; then
        echo "Error: EDITOR environment variable is not set."
        return 1
    fi

    if note_file_exists "$filepath"; then
        "$EDITOR" "$filepath"
    else
        echo "Error: File not found: $filepath"
        return 1
    fi
}

note_create_or_open() {
    local filepath="$1"
    local content="$2"

    if ! note_file_exists "$filepath"; then
        note_write_file "$filepath" "$content"
    fi

    note_open_editor "$filepath"
}

note_search() {
    local dir="$1"
    
    if ! command -v rg &> /dev/null; then
        echo "Error: rg (ripgrep) is not installed."
        return 1
    fi

    if command -v fzf &> /dev/null; then
        local selected
        # Search with rg, pipe to fzf with bat preview
        selected=$(rg --line-number --no-heading --color=always --smart-case "" "$dir" | \
            fzf $NOTES_FZF_OPTS --preview "bat --style=numbers --color=always --highlight-line {2} {1}" \
                --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')
        
        if [[ -n "$selected" ]]; then
            local file=$(echo "$selected" | cut -d: -f1)
            local line=$(echo "$selected" | cut -d: -f2)
            "$EDITOR" "+$line" "$file"
        fi
    else
        rg --smart-case "" "$dir"
    fi
}

note_find() {
    local dir="$1"

    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed."
        return 1
    fi

    local selected
    # Use fd to find files. 
    # - . : Search in current directory (which is $dir because we pass it as root)
    # "$dir" : The root directory to search
    # --type f : Only files
    # --color=always : Force color output for fzf
    selected=$(fd . "$dir" --type f --color=always | fzf $NOTES_FZF_OPTS --preview "bat --style=numbers --color=always {}" --preview-window 'right,50%,border-left')

    if [[ -n "$selected" ]]; then
        note_open_editor "$selected"
    fi
}

note_review() {
    local dir="$1"

    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed."
        return 1
    fi

    # Optimized Review Loop
    # Uses fzf --bind to execute editor without leaving fzf
    # This preserves scroll position and query
    rg --line-number --no-heading --color=always --smart-case "" "$dir" | \
        fzf $NOTES_FZF_OPTS \
            --preview "bat --style=numbers --color=always --highlight-line {2} {1}" \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
            --header "Press ENTER to edit, ESC to exit" \
            --bind "enter:execute($EDITOR +{2} {1})"
}
