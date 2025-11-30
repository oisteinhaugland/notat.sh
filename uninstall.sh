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
    sed -i '/# Notat.sh/,+1d' "$file" 2>/dev/null || true
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
# Final message
############################################################
ok "Notat.sh has been uninstalled."
info "You may also manually remove any backups or logs at: $INSTALL_DIR"
exit 0

