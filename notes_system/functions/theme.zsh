# Intended for zsh
# Theme management for Notat.sh

note_theme() {
    # Check dependencies
    if ! command -v bat &> /dev/null; then
        echo "Error: 'bat' is required for theming."
        return 1
    fi
    if ! command -v fzf &> /dev/null; then
        echo "Error: 'fzf' is required for selection."
        return 1
    fi

    echo "Select a theme for previews (ENTER to confirm, ESC to cancel):"
    
    # Get current theme
    local current_theme="${NOTES_BAT_THEME:-Visual Studio Dark+}"
    
    # Preview command: show a sample file with the selected theme
    # We'll use the current script or a dummy content for preview
    local sample_text=$'# Sample Note Content\n\n# Header Section\nThis is some regular text to show contrast.\n\n# Highlighted Section\nThis line is above the highlight.\nThis is the highlighted line to check visibility.\nThis line is below the highlight.\n\n# Code Example\nfunction demo() {\n    echo "Theme Preview"\n}'
    
    local preview_cmd="echo '$sample_text' | bat --language=bash --style=numbers --color=always --highlight-line 8 --theme {}"
    
    # Select theme
    local selected_theme
    selected_theme=$(bat --list-themes | fzf \
        --preview "$preview_cmd" \
        --preview-window "${NOTES_FZF_PREVIEW_WINDOW:-right,50%,border-left}" \
        --header "Current: $current_theme" \
        --layout=reverse --border --height=80%)
        
    if [[ -n "$selected_theme" ]]; then
        echo "Selected theme: $selected_theme"
        
        # Update config.zsh
        local config_file="$NOTES_SYSTEM_DIR/config.zsh"
        
        if [[ -f "$config_file" ]]; then
            # Replace the existing export line or append if not found
            if grep -q "export NOTES_BAT_THEME=" "$config_file"; then
                # Use sed to replace the line
                # We need to be careful with special characters in theme names
                # Escape the theme name for sed replacement
                local escaped_theme=$(echo "$selected_theme" | sed 's/[\/&]/\\&/g')
                
                # Use a temporary file for sed to avoid issues
                local temp_config=$(mktemp)
                sed "s/^export NOTES_BAT_THEME=.*$/export NOTES_BAT_THEME=\"$escaped_theme\"/" "$config_file" > "$temp_config"
                mv "$temp_config" "$config_file"
            else
                echo "" >> "$config_file"
                echo "# Bat Theme for Previews" >> "$config_file"
                echo "export NOTES_BAT_THEME=\"$selected_theme\"" >> "$config_file"
            fi
            
            echo "Configuration updated in $config_file"
            # Update current session
            export NOTES_BAT_THEME="$selected_theme"
        else
            echo "Error: Config file not found at $config_file"
            return 1
        fi
    else
        echo "No theme selected."
    fi
}
