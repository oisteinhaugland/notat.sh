#!/usr/bin/env bash
# Notat.sh Installer
set -euo pipefail

############################################################
# Flags & Defaults
############################################################
FORCE=false
QUIET=false
DRY_RUN=false

# Install location (XDG-compliant)
XDG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
INSTALL_DIR="$XDG_DIR/notat.sh"

# Script/repo location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/notes_system"

LOGFILE="$INSTALL_DIR/install.log"

############################################################
# Color support
############################################################
use_color=true
if [[ ! -t 1 || -n "${NO_COLOR:-}" || "$QUIET" = true ]]; then
    use_color=false
fi

color() {
    local code="$1"; shift
    $use_color && printf "\033[%sm%s\033[0m\n" "$code" "$*" || printf "%s\n" "$*"
}

info()  { color "36" "$@"; }  # cyan
ok()    { color "32" "$@"; }  # green
warn()  { color "33" "$@"; }  # yellow
error() { color "31" "$@"; }  # red

say() { $QUIET || echo "$@"; }

############################################################
# run_cmd wrapper for DRY-RUN
############################################################
run_cmd() {
    local cmd="$*"
    $QUIET || echo "+ $cmd"
    $DRY_RUN || eval "$cmd"
}

############################################################
# Cross-platform path resolution (readlink -f not on macOS)
############################################################
get_real_path() {
    local path="$1"
    
    # Try realpath (available on most modern systems)
    if command -v realpath > /dev/null 2>&1; then
        realpath "$path" 2>/dev/null && return 0
    fi
    
    # Try readlink -f (Linux)
    if readlink -f "$path" 2>/dev/null; then
        return 0
    fi
    
    # macOS fallback: use pwd with cd
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd)
    elif [[ -L "$path" ]]; then
        # For symlinks, resolve recursively
        local target
        target=$(readlink "$path")
        if [[ "$target" == /* ]]; then
            echo "$target"
        else
            echo "$(dirname "$path")/$target"
        fi
    else
        # Last resort: return as-is
        echo "$path"
    fi
}

############################################################
# Help
############################################################
show_help() {
cat <<EOF
Notat.sh Installer

Usage: ./install.sh [options]

Options:
  -f, --force      Overwrite without asking
  -q, --quiet      Suppress output (still logs to file)
      --dry-run    Show actions without executing
  -h, --help       Show help

EOF
}

############################################################
# Parse Flags
############################################################
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--force) FORCE=true ;;
        -q|--quiet) QUIET=true ;;
        --dry-run)  DRY_RUN=true ;;
        -h|--help)  show_help; exit 0 ;;
        *) error "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

############################################################
# Startup
############################################################
say "Installing Notat.sh..."

# Use temporary log location during installation
# This prevents creating INSTALL_DIR before checking if it exists
TEMP_INSTALL_LOG="/tmp/notat-install-$(date +%s).log"
LOGFILE="$TEMP_INSTALL_LOG"

# Start logging to temp location
exec > >(tee -a "$LOGFILE") 2>&1

############################################################
# Validate REPO_DIR
############################################################
if [[ ! -d "$REPO_DIR" ]]; then
    error "Repository directory not found: $REPO_DIR"
    exit 1
fi

############################################################
# Dependency Check (fatal on missing critical deps)
############################################################
check_command() {
    local cmd="$1"
    shift
    local alternatives=("$@")
    
    # Check primary command
    if command -v "$cmd" > /dev/null 2>&1; then
        return 0
    fi
    
    # Check alternatives
    for alt in "${alternatives[@]}"; do
        if command -v "$alt" > /dev/null 2>&1; then
            return 0
        fi
    done
    
    return 1
}

check_deps() {
    say "Checking dependencies..."
    local missing=()

    # Check each dependency with alternatives
    check_command rg || missing+=("ripgrep (rg)")
    check_command fzf || missing+=("fzf")
    check_command bat batcat || missing+=("bat")
    check_command fd fdfind fd-find || missing+=("fd")
    check_command git || missing+=("git")

    if (( ${#missing[@]} )); then
        error "Missing critical dependencies: ${missing[*]}"
        error ""
        error "Install them before continuing:"
        error "  macOS:  brew install ripgrep fzf bat fd git"
        error "  Ubuntu: apt install ripgrep fzf bat fd-find git"
        error "  Arch:   pacman -S ripgrep fzf bat fd git"
        exit 1
    fi
    
    ok "All dependencies found."
    
    # Check optional dependencies
    if ! check_command gocryptfs; then
        warn "Optional: gocryptfs not found (required for encrypted vaults)"
    fi
}

check_deps

############################################################
# Ensure symlink with backup handling
############################################################
ensure_symlink() {
    # If a file/directory exists and is NOT correct symlink
    if [[ -e "$INSTALL_DIR" && ! -L "$INSTALL_DIR" ]]; then
        if ! $FORCE; then
            read -rp "Directory exists at $INSTALL_DIR. Overwrite? [y/N] " ans
            [[ "$ans" =~ ^[Yy]$ ]] || { warn "Aborting."; exit 1; }
        fi

        backup="${INSTALL_DIR}.backup.$(date +%s)"
        warn "Backing up existing directory to $backup"
        run_cmd mv "$INSTALL_DIR" "$backup"
        run_cmd mkdir -p "$(dirname "$INSTALL_DIR")"
    fi

    # If it's a symlink but to the wrong place
    if [[ -L "$INSTALL_DIR" ]]; then
        if [[ "$(readlink "$INSTALL_DIR")" == "$REPO_DIR" ]]; then
            ok "Symlink already correct."
            return
        else
            warn "Replacing incorrect symlink."
            run_cmd rm "$INSTALL_DIR"
        fi
    fi

    # Create correct symlink
    run_cmd ln -s "$REPO_DIR" "$INSTALL_DIR"
    ok "Linked: $INSTALL_DIR → $REPO_DIR"
}

ensure_symlink

############################################################
# Detect Shell and Config File
############################################################
detect_shell_config() {
    # Check SHELL environment variable (more reliable than version vars in installer context)
    case "${SHELL:-}" in
        */zsh)  echo "$HOME/.zshrc" && return;;
        */bash) echo "$HOME/.bashrc" && return;;
        */fish) echo "$HOME/.config/fish/config.fish" && return;;
    esac
    
    # If SHELL isn't set or is unknown, return empty for interactive prompt
    echo ""
}

prompt_shell_choice() {
    local choice
    echo ""
    echo "Which shell do you use?"
    echo "  1) zsh"
    echo "  2) bash"
    echo "  3) fish"
    echo "  4) other (manual setup required)"
    echo ""
    read -rp "Enter choice [1-4]: " choice
    
    case "$choice" in
        1) echo "$HOME/.zshrc";;
        2) echo "$HOME/.bashrc";;
        3) echo "$HOME/.config/fish/config.fish";;
        4) echo "";;
        *) echo "" && warn "Invalid choice. Manual setup required.";;
    esac
}

CONFIG_FILE="$(detect_shell_config)"

# If detection failed, prompt user
if [[ -z "$CONFIG_FILE" ]]; then
    CONFIG_FILE="$(prompt_shell_choice)"
fi

############################################################
# Add source line idempotently
############################################################
add_source_line() {
    local file="$1"
    local shell="$(basename "$file")"
    local line=""

    case "$shell" in
        .zshrc|.bashrc) line="source \"$INSTALL_DIR/init.zsh\"" ;;
        config.fish)    line="source \"$INSTALL_DIR/init.fish\"" ;;
        *) return ;;
    esac

    [[ ! -w "$file" ]] && { warn "Cannot write to $file"; return; }

    if grep -Fq "$line" "$file"; then
        ok "Config already present in $file"
    else
        run_cmd "printf \"\n# Notat.sh\n%s\n\" \"$line\" >> \"$file\""
        ok "Added to $file"
    fi
}

if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]]; then
    add_source_line "$CONFIG_FILE"
else
    warn "Shell config not detected. Add manually:"
    warn "source \"$INSTALL_DIR/init.zsh\""
fi

############################################################
# Neovim Setup Prompt
############################################################
# Check if Neovim integration already exists
NVIM_ALREADY_SETUP=false
if [[ -L "$HOME/.config/nvim/lua/notat.lua" ]]; then
    existing_target=$(readlink "$HOME/.config/nvim/lua/notat.lua")
    expected_target="$REPO_DIR/nvim_integration.lua"
    if [[ "$existing_target" == "$expected_target" ]]; then
        NVIM_ALREADY_SETUP=true
        ok "Neovim integration already configured."
    fi
fi

if ! $NVIM_ALREADY_SETUP; then
    echo ""
    read -rp "Do you want to set up Neovim integration? [y/N] " nvim_ans
    if [[ "$nvim_ans" =~ ^[Yy]$ ]]; then
        if [[ -f "$REPO_DIR/setup_nvim.sh" ]]; then
            run_cmd "$REPO_DIR/setup_nvim.sh"
        else
            warn "setup_nvim.sh not found."
        fi
    fi
fi

############################################################
# Move log to final location
############################################################
if [[ -n "$TEMP_INSTALL_LOG" && -f "$TEMP_INSTALL_LOG" ]]; then
    # Determine final log location
    if [[ -L "$INSTALL_DIR" ]]; then
        # If it's a symlink, put log in the actual directory
        FINAL_LOG="$(get_real_path "$INSTALL_DIR")/install.log"
    else
        FINAL_LOG="$INSTALL_DIR/install.log"
    fi
    
    mkdir -p "$(dirname "$FINAL_LOG")"
    cp "$TEMP_INSTALL_LOG" "$FINAL_LOG" 2>/dev/null || true
    rm -f "$TEMP_INSTALL_LOG"
    LOGFILE="$FINAL_LOG"
    info "Installation log saved to: $FINAL_LOG"
fi

############################################################
# Post-Install Validation
############################################################
validate_installation() {
    local errors=()
    
    say ""
    say "Validating installation..."
    
    # Check symlink
    if [[ ! -L "$INSTALL_DIR" ]]; then
        errors+=("Symlink not created at $INSTALL_DIR")
    elif [[ "$(readlink "$INSTALL_DIR")" != "$REPO_DIR" ]]; then
        errors+=("Symlink points to wrong location")
    fi
    
    # Check core files exist
    if [[ ! -f "$REPO_DIR/init.zsh" ]]; then
        errors+=("Core file missing: init.zsh")
    fi
    
    if [[ ! -f "$REPO_DIR/config.zsh" ]]; then
        errors+=("Core file missing: config.zsh")
    fi
    
    # Check shell config was updated (if applicable)
    if [[ -n "$CONFIG_FILE" && -f "$CONFIG_FILE" ]]; then
        if ! grep -Fq "source \"$INSTALL_DIR/init.zsh\"" "$CONFIG_FILE"; then
            errors+=("Shell config not updated: $CONFIG_FILE")
        fi
    fi
    
    # Report results
    if (( ${#errors[@]} )); then
        error "Validation failed:"
        for err in "${errors[@]}"; do
            error "  - $err"
        done
        return 1
    else
        ok "Validation passed!"
        return 0
    fi
}

validate_installation || {
    error "Installation completed with errors. Please review the log:"
    error "  $LOGFILE"
    exit 1
}

ok "Installation complete!"
say "Restart your shell or run: source \"$CONFIG_FILE\""

exit 0

