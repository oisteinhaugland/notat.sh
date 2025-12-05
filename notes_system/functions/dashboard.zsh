# Intended for zsh
# Dashboard functions

note_dashboard_open() {
    note_check_deps || return 1

    local today_note
    today_note=$(note_daily_path "$(date +%Y-%m-%d)")
    
    local actions_dir="$NOTES_BASE_DIR/actions"
    
    # Check if today's note exists, otherwise we might just show actions
    local daily_source=""
    if [[ -f "$today_note" ]]; then
        daily_source="$today_note"
    fi

    # We want to gather lines from:
    # 1. Today's daily note (if exists) -> Non-closed tasks
    # 2. Actions dir -> Non-closed tasks
    
    # Pattern for non-closed tasks: Starts with optional whitespace, then one of . = , > ?
    # We exclude 'x' (Done).
    local task_pattern="^\s*[.=>?,]"

    local preview_cmd=$(note_get_preview_cmd)
    local opener_script="/tmp/notat_opener_$$.sh"
    local editor_cmd="${EDITOR:-vim}"

    # Create opener script (same pattern as in core.zsh)
    cat <<EOF > "$opener_script"
#!/bin/sh
file_line="\$1"
file="\${file_line%:*}"
line="\${file_line##*:}"
$editor_cmd "+\$line" "\$file"
EOF
    chmod +x "$opener_script"

    # Construct the rg command
    # We need to search multiple paths.
    # If daily_source is empty, we only search actions_dir.
    
    local search_paths=("$actions_dir")
    if [[ -n "$daily_source" ]]; then
        search_paths+=("$daily_source")
    fi

    # Run rg on the paths
    # We use --no-heading --line-number to get standard grep output: file:line:content
    # Then we format it for fzf
    
    rg --line-number --no-heading --color=never --smart-case "$task_pattern" "${search_paths[@]}" 2>/dev/null | \
        sed -E 's/^(.+):([0-9]+):(.*)$/\3\t\1:\2\t\2/' | \
        fzf ${NOTES_FZF_OPTS:-} \
            --delimiter '\t' \
            --with-nth 1 \
            --prompt "Dashboard> " \
            --header "ENTER: Edit | ESC: Exit" \
            --preview "$preview_cmd {2}" \
            --preview-window "${NOTES_FZF_PREVIEW_WINDOW:-right,50%,border-left}" \
            --bind "enter:execute($opener_script {2})"

    rm -f "$opener_script"
}
