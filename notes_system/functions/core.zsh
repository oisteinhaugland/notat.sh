# Intended for zsh and bash
# Core functions for Notetaking System

# --- Helpers ---

note_check_deps() {
    local deps=(rg fzf bat fd)
    local missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done

    if (( ${#missing[@]} )); then
        echo "Error: Missing dependencies: ${missing[*]}"
        return 1
    fi
    return 0
}

note_is_empty() {
    local dir="$1"
    [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]
}

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
    local line="${2:-}"
    
    local editor_cmd="${EDITOR:-}"
    
    if [[ -z "$editor_cmd" ]]; then
        if command -v nvim &> /dev/null; then
            editor_cmd="nvim"
        elif command -v vim &> /dev/null; then
            editor_cmd="vim"
        elif command -v nano &> /dev/null; then
            editor_cmd="nano"
        else
            echo "Error: EDITOR not set and no fallback editors found."
            return 1
        fi
    fi

    if note_file_exists "$filepath"; then
        if [[ -n "$line" ]]; then
            "$editor_cmd" "+$line" "$filepath"
        else
            "$editor_cmd" "$filepath"
        fi
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

# --- Helpers ---

note_get_preview_cmd() {
    # Returns the absolute path to the preview script
    local preview_script=""
    
    # Try to derive from NOTES_BASE_DIR if set
    if [[ -n "$NOTES_BASE_DIR" ]]; then
        # Assuming standard structure: parent of NOTES_BASE_DIR contains notes_system
        # This is a bit fragile if NOTES_BASE_DIR is customized.
        local potential_path="${NOTES_BASE_DIR}/../notes_system/bin/preview.sh"
        if [[ -f "$potential_path" ]]; then
            # Resolve to absolute path
            if command -v readlink &> /dev/null; then
                preview_script=$(readlink -f "$potential_path")
            else
                # Fallback for systems without readlink -f (e.g. macOS default)
                # But user is on Linux.
                preview_script=$(realpath "$potential_path")
            fi
            echo "$preview_script"
            return 0
        fi
    fi
    
    # Fallback: assume it's in the PATH
    echo "preview.sh"
}


note_sanitize() {
    local input="$1"
    echo "$input" | tr ' ' '_' | tr -cd '[:alnum:]_-'
}

note_prompt() {
    local prompt_text="$1"
    local input=""
    
    if [[ ! -t 0 ]]; then
        read input
    else
        echo -n "$prompt_text"
        read input
    fi
    echo "$input"
}

note_generic_create() {
    local type="$1"
    local input="${2:-}"
    
    # 1. Get Input if missing
    if [[ -z "$input" ]]; then
        input=$(note_prompt "Enter $type title/name: ")
    fi
    
    if [[ -z "$input" ]]; then
        echo "Error: Input cannot be empty."
        return 1
    fi

    # 2. Resolve functions dynamically
    local path_func="note_${type}_path"
    local content_func="note_${type}_content"

    if ! command -v "$path_func" &> /dev/null || ! command -v "$content_func" &> /dev/null; then
        echo "Error: Unknown note type '$type' (functions not found)."
        return 1
    fi

    # 3. Generate Data (Pure)
    # We capture stdout from these functions
    local filepath=$($path_func "$input")
    local content=$($content_func "$input")

    # 4. Side Effect (IO)
    note_create_or_open "$filepath" "$content"
}

# --- Core Actions ---

# --- Core Actions ---

# 1. Search (Single-shot Inline)
note_search() {
    local dir="$1"
    local pattern="${2:-.}" # Default to "." to match non-empty lines
    
    note_check_deps || return 1
    if note_is_empty "$dir"; then echo "Directory is empty: $dir"; return 0; fi

    local editor_cmd="${EDITOR:-vim}"
    local selected
    
    # Run in subshell to keep relative paths
    # rg: --color=never ensures plain text output (White/Default terminal color)
    # sed: moves "File:Line" to the end, separated by tab
    # fzf: displays only the second field (Content)
    local preview_cmd=$(note_get_preview_cmd)

    selected=$( (cd "$dir" && \
        rg --line-number --no-heading --color=never --smart-case "$pattern" . | \
        sed -E 's/^(.+):([0-9]+):(.*)$/\3\t\1:\2/' | \
        fzf ${NOTES_FZF_OPTS:-} \
            --delimiter '\t' \
            --with-nth 1 \
            --prompt "Search> " \
            --header "ENTER: Edit" \
            --preview "$preview_cmd {2}" \
            --preview-window 'up,60%,border-bottom' ) )
    
    if [[ -n "$selected" ]]; then
        # Extract File:Line from the second field (hidden)
        # Extract File:Line from the second field (hidden)
        local file_line=$(echo "$selected" | awk -F'\t' '{print $2}')
        local file="${file_line%:*}"
        local line="${file_line##*:}"
        # Construct absolute path since we are outside the subshell now
        note_open_editor "$dir/$file" "$line"
    fi
}

# 2. Pick (Single-shot File)
note_pick() {
    local dir="$1"

    note_check_deps || return 1
    if note_is_empty "$dir"; then echo "Directory is empty: $dir"; return 0; fi

    local selected
    # fd -> fzf -> open -> exit
    # Run in subshell for relative paths
    local preview_cmd=$(note_get_preview_cmd)
    # fd -> fzf -> open -> exit
    # Run in subshell for relative paths
    selected=$( (cd "$dir" && fd . . --type f --color=always | \
        fzf ${NOTES_FZF_OPTS:-} --preview "$preview_cmd {}" --preview-window 'right,50%,border-left') )

    if [[ -n "$selected" ]]; then
        note_open_editor "$dir/$selected"
    fi
}

# 3. Review Inline (Looped Inline)
note_review_inline() {
    local dir="$1"
    local pattern="${2:-.}" # Default to "." to match non-empty lines

    note_check_deps || return 1
    if note_is_empty "$dir"; then echo "Directory is empty: $dir"; return 0; fi

    local editor_cmd="${EDITOR:-vim}"
    
    # Create helper script for opening files from fzf
    # This avoids quoting hell inside fzf's execute binding
    local opener_script="/tmp/notat_opener_$$.sh"
    cat <<EOF > "$opener_script"
#!/bin/sh
# Input: "File:Line" (from fzf {2})
# Input: "File:Line" (from fzf {2})
file_line="\$1"
file="\${file_line%:*}"
line="\${file_line##*:}"
# Open editor
$editor_cmd "+\$line" "\$file"
EOF
    chmod +x "$opener_script"

    # Run in subshell
    # rg: --color=never for plain text
    local preview_cmd=$(note_get_preview_cmd)

    # Run in subshell
    # rg: --color=never for plain text
    (cd "$dir" && \
        rg --line-number --no-heading --color=never --smart-case "$pattern" . | \
        sed -E 's/^(.+):([0-9]+):(.*)$/\3\t\1:\2/' | \
        fzf ${NOTES_FZF_OPTS:-} \
            --delimiter '\t' \
            --with-nth 1 \
            --prompt "Search> " \
            --header "ENTER: Edit | ESC: Exit" \
            --preview "$preview_cmd {2}" \
            --preview-window 'up,60%,border-bottom' \
            --bind "enter:execute($opener_script {2})" )
            
    # Cleanup
    rm -f "$opener_script"
}

# 4. Review File (Looped File)
note_review_file() {
    local dir="$1"

    note_check_deps || return 1
    if note_is_empty "$dir"; then echo "Directory is empty: $dir"; return 0; fi

    local editor_cmd="${EDITOR:-vim}"

    # fd -> fzf (bind enter to execute editor) -> loop
    local preview_cmd=$(note_get_preview_cmd)

    # fd -> fzf (bind enter to execute editor) -> loop
    (cd "$dir" && fd . . --type f --color=always | \
        fzf ${NOTES_FZF_OPTS:-} \
            --preview "$preview_cmd {}" \
            --preview-window 'right,50%,border-left' \
            --header "Press ENTER to edit, ESC to exit (Loop)" \
            --bind "enter:execute($editor_cmd {1})")
}

# Legacy/Alias Helpers
note_review() { note_review_inline "$@"; } # Default review was inline, but modules will override
note_search_pattern() { note_search "$2" "$1"; } # pattern, dir -> dir, pattern

# --- Archive Functions ---

note_archive_search() {
    local type="$1"  # d, t, a, j, or empty for all
    local pattern="${2:-.}"
    local archive_dir="$NOTES_ARCHIVE_DIR"
    
    if [[ -n "$type" ]]; then
        case "$type" in
            d) archive_dir="$NOTES_ARCHIVE_DIR/daily" ;;
            t) archive_dir="$NOTES_ARCHIVE_DIR/thoughts" ;;
            a) archive_dir="$NOTES_ARCHIVE_DIR/actions" ;;
            j) archive_dir="$NOTES_ARCHIVE_DIR/journals" ;;
            *) echo "Unknown archive type: $type" && return 1 ;;
        esac
    fi
    
    note_search "$archive_dir" "$pattern"
}

note_archive_review() {
    local type="$1"  # d, t, a, j, or empty for all
    local archive_dir="$NOTES_ARCHIVE_DIR"
    
    if [[ -n "$type" ]]; then
        case "$type" in
            d) archive_dir="$NOTES_ARCHIVE_DIR/daily" ;;
            t) archive_dir="$NOTES_ARCHIVE_DIR/thoughts" ;;
            a) archive_dir="$NOTES_ARCHIVE_DIR/actions" ;;
            j) archive_dir="$NOTES_ARCHIVE_DIR/journals" ;;
            *) echo "Unknown archive type: $type" && return 1 ;;
        esac
    fi
    
    note_review_file "$archive_dir"
}
