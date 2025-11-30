#!/bin/bash

# Notat.sh Installer

set -e

echo "Installing Notat.sh..."

# 1. Check Dependencies
echo "Checking dependencies..."
deps=("rg" "fzf" "bat")
missing_deps=()

for dep in "${deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        missing_deps+=("$dep")
    fi
done

if [ ${#missing_deps[@]} -ne 0 ]; then
    echo "Warning: The following dependencies are missing: ${missing_deps[*]}"
    echo "Please install them using your package manager (e.g., apt, brew, pacman)."
else
    echo "All dependencies found."
fi

# 2. Install Location
INSTALL_DIR="$HOME/.notat.sh"
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/notes_system"

if [ -d "$INSTALL_DIR" ]; then
    echo "Directory $INSTALL_DIR already exists."
    read -p "Overwrite? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting."
        exit 1
    fi
    rm -rf "$INSTALL_DIR"
fi

echo "Symlinking $REPO_DIR to $INSTALL_DIR..."
ln -s "$REPO_DIR" "$INSTALL_DIR"

# 3. Shell Configuration
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    # Detect based on default shell
    if [[ "$SHELL" == */zsh ]]; then
        SHELL_CONFIG="$HOME/.zshrc"
    elif [[ "$SHELL" == */bash ]]; then
        SHELL_CONFIG="$HOME/.bashrc"
    fi
fi

if [ -n "$SHELL_CONFIG" ] && [ -f "$SHELL_CONFIG" ]; then
    SOURCE_LINE="source $INSTALL_DIR/init.zsh"
    if grep -Fq "$SOURCE_LINE" "$SHELL_CONFIG"; then
        echo "Configuration already present in $SHELL_CONFIG"
    else
        echo "Adding source line to $SHELL_CONFIG..."
        echo "" >> "$SHELL_CONFIG"
        echo "# Notat.sh" >> "$SHELL_CONFIG"
        echo "$SOURCE_LINE" >> "$SHELL_CONFIG"
        echo "Added to $SHELL_CONFIG. Please restart your shell or run 'source $SHELL_CONFIG'."
    fi
else
    echo "Could not detect shell config file. Please add the following line manually:"
    echo "source $INSTALL_DIR/init.zsh"
fi

echo "Installation complete!"
