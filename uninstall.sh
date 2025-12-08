#!/usr/bin/env bash
set -euo pipefail

############################################################
# Detect install location (XDG-compliant)
############################################################
XDG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
INSTALL_DIR="$XDG_DIR/notat.sh"

############################################################
# Helper: simple colored output
############################################################
use_color=true
if [[ ! -t 1 || -n "${NO_COLOR:-}" ]]; then
    use_color=false
fi

color() {
    local code="$1"; shift
    $use_color && printf "\033[%sm%s\033[0m\n" "$code" "$*" || printf "%s\n" "$*"
}

info()  { color "36" "$@"; }
ok()    { color "32" "$@"; }
warn()  { color "33" "$@"; }
error() { color "31" "$@"; }

############################################################
# Cross-platform sed in-place editing
############################################################
sed_inplace() {
    local pattern="$1"
    local file="$2"
    
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS requires empty string after -i
        sed -i '' "$pattern" "$file" 2>/dev/null || true
    else
        # Linux uses -i directly
        sed -i "$pattern" "$file" 2>/dev/null || true
    fi
}

############################################################
# Confirm action
############################################################
read -rp "Uninstall Notat.sh? [y/N] " ans
if [[ ! "$ans" =~ ^[Yy]$ ]]; then
    warn "Uninstall cancelled."
    exit 0
fi

info "Uninstalling Notat.sh..."

############################################################
# Remove install directory (symlink only)
############################################################
if [[ -L "$INSTALL_DIR" ]]; then
    rm "$INSTALL_DIR"
    ok "Removed symlink: $INSTALL_DIR"
elif [[ -d "$INSTALL_DIR" ]]; then
    warn "$INSTALL_DIR is a directory, not a symlink — not removing."
else
    warn "No Notat.sh installation found at $INSTALL_DIR"
fi

############################################################
# Remove configuration lines
############################################################
remove_source_lines() {
    local file="$1"
    [[ -f "$file" ]] || return

    # Remove the "# Notat.sh" line and the line below it (the source line)
    # If the lines are absent, sed does nothing.
    sed_inplace '/# Notat.sh/,+1d' "$file"
}

for cfg in \
    "$HOME/.bashrc" \
    "$HOME/.zshrc" \
    "$HOME/.config/fish/config.fish"
do
    if [[ -f "$cfg" ]]; then
        remove_source_lines "$cfg"
        ok "Cleaned config: $cfg"
    fi
done

############################################################
# Remove Neovim integration (if exists)
############################################################
info "Checking for Neovim integration..."

NVIM_CLEANED=false

# Remove symlink
if [[ -L "$HOME/.config/nvim/lua/notat.lua" ]]; then
    rm "$HOME/.config/nvim/lua/notat.lua"
    ok "Removed Neovim symlink: ~/.config/nvim/lua/notat.lua"
    NVIM_CLEANED=true
fi

# Remove config file
if [[ -f "$HOME/.config/nvim/lua/notat_config.lua" ]]; then
    rm "$HOME/.config/nvim/lua/notat_config.lua"
    ok "Removed Neovim config: ~/.config/nvim/lua/notat_config.lua"
    NVIM_CLEANED=true
fi

# Remove require lines from init.lua
if [[ -f "$HOME/.config/nvim/init.lua" ]]; then
    # Remove any lines that require notat modules
    if grep -q "require.*notat" "$HOME/.config/nvim/init.lua" 2>/dev/null; then
        sed_inplace '/require.*notat/d' "$HOME/.config/nvim/init.lua"
        ok "Cleaned Neovim init.lua"
        NVIM_CLEANED=true
    fi
fi

if ! $NVIM_CLEANED; then
    info "No Neovim integration found."
fi

############################################################
# Final message
############################################################
ok "Notat.sh has been uninstalled."
info "You may also manually remove any backups or logs at: $INSTALL_DIR"
exit 0

