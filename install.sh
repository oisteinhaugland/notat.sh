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
mkdir -p "$INSTALL_DIR"

# Start logging
exec > >(tee -a "$LOGFILE") 2>&1

############################################################
# Validate REPO_DIR
############################################################
if [[ ! -d "$REPO_DIR" ]]; then
    error "Repository directory not found: $REPO_DIR"
    exit 1
fi

############################################################
# Dependency Check (non-fatal)
############################################################
check_deps() {
    say "Checking dependencies..."
    local deps=(rg fzf bat fd git)
    local missing=()

    for dep in "${deps[@]}"; do
        command -v "$dep" >/dev/null 2>&1 || missing+=("$dep")
    done

    if (( ${#missing[@]} )); then
        warn "Missing dependencies: ${missing[*]}"
        warn "Install them manually for full functionality."
    else
        ok "All dependencies found."
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
        run_cmd mkdir -p "$INSTALL_DIR"
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
    if [[ -n "${ZSH_VERSION:-}" ]]; then echo "$HOME/.zshrc" && return; fi
    if [[ -n "${BASH_VERSION:-}" ]]; then echo "$HOME/.bashrc" && return; fi

    case "${SHELL:-}" in
        */zsh)  echo "$HOME/.zshrc";;
        */bash) echo "$HOME/.bashrc";;
        */fish) echo "$HOME/.config/fish/config.fish";;
        *) echo "";;
    esac
}

CONFIG_FILE="$(detect_shell_config)"

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
echo ""
read -rp "Do you want to set up Neovim integration? [y/N] " nvim_ans
if [[ "$nvim_ans" =~ ^[Yy]$ ]]; then
    if [[ -f "$REPO_DIR/setup_nvim.sh" ]]; then
        run_cmd "$REPO_DIR/setup_nvim.sh"
    else
        warn "setup_nvim.sh not found."
    fi
fi

ok "Installation complete!"
say "Restart your shell or run: source \"$CONFIG_FILE\""

exit 0

