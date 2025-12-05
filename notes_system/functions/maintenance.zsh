# Intended for zsh
# Maintenance functions for Notat.sh

# 1. Backup (Git Sync)
note_backup() {
    local msg="${1:-Backup $(date '+%Y-%m-%d %H:%M:%S')}"
    
    note_check_deps || return 1
    
    if ! git -C "$NOTES_BASE_DIR" rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: NOTES_BASE_DIR ($NOTES_BASE_DIR) is not a git repository."
        echo "Run 'git init' in that directory to enable backups."
        return 1
    fi
    
    echo "💾 Backing up notes..."
    (cd "$NOTES_BASE_DIR" && \
     git add . && \
     git commit -m "$msg" && \
     git pull --rebase && \
     git push)
     
    if [[ $? -eq 0 ]]; then
        echo "✅ Backup complete."
    else
        echo "❌ Backup failed."
        return 1
    fi
}

# 2. Stats (Counts)
note_stats() {
    note_check_deps || return 1
    
    echo "📊 Notat Stats:"
    echo "----------------"
    
    # Count files in standard directories
    local dirs=(daily thoughts actions journals people resources archive)
    for dir in "${dirs[@]}"; do
        local count=0
        if [[ -d "$NOTES_BASE_DIR/$dir" ]]; then
            count=$(fd . "$NOTES_BASE_DIR/$dir" --type f | wc -l)
        fi
        echo "  $dir: $count notes"
    done

    echo ""
    echo "  Task Summary:"
    echo "  -------------"
    
    if [[ -d "$NOTES_BASE_DIR" ]]; then
        # Count occurrences of task markers at start of line
        # Markers: . (Open), = (Active), , (Parked), > (Waiting), ? (Question), x (Done)
        rg --no-heading --no-line-number --no-filename -o "^\s*([.=>?,x])" "$NOTES_BASE_DIR" 2>/dev/null \
            | sed 's/^\s*//' \
            | sort \
            | uniq -c \
            | awk '{print "    " $2 ": " $1}'
    fi
}

# 3. Prune (Empty file cleanup)
note_prune() {
    note_check_deps || return 1
    
    echo "🧹 Pruning empty files..."
    
    # Find empty files
    local empty_files
    empty_files=$(fd . "$NOTES_BASE_DIR" --type f --size -1b)
    
    if [[ -z "$empty_files" ]]; then
        echo "No empty files found."
        return 0
    fi
    
    echo "Found empty files:"
    echo "$empty_files"
    echo ""
    
    # Prompt for confirmation
    echo -n "Delete these files? [y/N] "
    local response
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "$empty_files" | xargs rm
        echo "Deleted."
    else
        echo "Aborted."
    fi
}

# 4. Health Check (Migrated from health.zsh)
note_health() {
    echo "Notat.sh Health Check"
    echo "====================="
    echo ""

    local errors=0

    # 1. Check Dependencies
    echo "Checking Dependencies:"
    local deps=(rg fzf bat fd git)
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            echo "  [OK] $dep found: $(command -v "$dep")"
        else
            echo "  [FAIL] $dep NOT found"
            ((errors++))
        fi
    done
    echo ""

    # 2. Check Environment Variables
    echo "Checking Environment:"
    if [[ -n "$NOTES_BASE_DIR" ]]; then
        echo "  [OK] NOTES_BASE_DIR set to: $NOTES_BASE_DIR"
        if [[ -d "$NOTES_BASE_DIR" ]]; then
            echo "       Directory exists."
        else
            echo "       [WARN] Directory does not exist."
        fi
    else
        echo "  [FAIL] NOTES_BASE_DIR not set."
        ((errors++))
    fi

    if [[ -n "$EDITOR" ]]; then
        echo "  [OK] EDITOR set to: $EDITOR"
    else
        echo "  [WARN] EDITOR not set. Will fallback to nvim/vim/nano."
    fi
    echo ""

    # 3. Check Neovim Integration
    echo "Checking Neovim Integration:"
    if command -v nvim &> /dev/null; then
        # Try to load the module in headless mode
        if nvim --headless -c "lua local ok = pcall(require, 'notat'); if ok then os.exit(0) else os.exit(1) end" 2>/dev/null; then
             echo "  [OK] 'notat' lua module loadable."
        else
             echo "  [FAIL] 'notat' lua module NOT loadable."
             echo "         Run 'setup_nvim.sh' to fix."
             ((errors++))
        fi
    else
        echo "  [SKIP] Neovim not installed."
    fi
    echo ""

    # Summary
    if (( errors == 0 )); then
        echo "Health Check Passed! System is ready."
    else
        echo "Health Check Failed with $errors error(s)."
        return 1
    fi
}
