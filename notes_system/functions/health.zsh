# Intended for zsh
# Health checks for Notat.sh

notat_health() {
    echo "Notat.sh Health Check"
    echo "====================="
    echo ""

    local errors=0

    # 1. Check Dependencies
    echo "Checking Dependencies:"
    local deps=(rg fzf bat fd)
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
