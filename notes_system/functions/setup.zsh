# Intended for zsh
# Onboarding Wizard for Notat.sh

# Helper: Check if component is configured
_setup_check_vault() {
    local env="$1"
    local cipher_dir="$HOME/.notes-encrypted/$env"
    [[ -d "$cipher_dir" && -f "$cipher_dir/gocryptfs.conf" ]]
}

_setup_check_git() {
    local env="$1"
    local cipher_dir="$HOME/.notes-encrypted/$env"
    [[ -d "$cipher_dir/.git" ]] && cd "$cipher_dir" && git remote get-url origin &>/dev/null
}

_setup_check_keyfile() {
    local env="$1"
    [[ -f "$HOME/.config/notat/keys/${env}.key" ]]
}

_setup_check_mounted() {
    local env="$1"
    mount | grep -q "$HOME/notes/$env"
}

note_setup() {
    local env_name="$1"
    local force_mode=false
    
    # Check for --force flag
    if [[ "$2" == "--force" || "$1" == "--force" ]]; then
        force_mode=true
        env_name="${env_name//--force/}"
        env_name="${env_name## }"
    fi
    
    echo "Welcome to the Notat Setup Wizard! 🧙‍♂️"
    echo "-------------------------------------"
    
    # 1. Dependency Check
    if ! command -v gocryptfs &> /dev/null; then
        echo "❌ Error: gocryptfs is NOT installed."
        echo "Please install it first:"
        echo "  Linux: sudo apt install gocryptfs"
        echo "  macOS: brew install --cask macfuse && brew install rfjakob/gocryptfs/gocryptfs"
        return 1
    fi
    echo "✅ Dependencies found."
    echo ""

    # 2. Environment Selection
    if [[ -z "$env_name" ]]; then
        echo "Which environment would you like to set up?"
        echo "Examples: personal, work, project-x"
        echo -n "Environment Name [personal]: "
        read -r input_name
        env_name="${input_name:-personal}"
    fi
    
    # 3. Detect existing configuration
    local vault_exists=$(_setup_check_vault "$env_name" && echo true || echo false)
    local git_exists=$(_setup_check_git "$env_name" && echo true || echo false)
    local keyfile_exists=$(_setup_check_keyfile "$env_name" && echo true || echo false)
    local is_mounted=$(_setup_check_mounted "$env_name" && echo true || echo false)
    
    # Show current status
    echo "Current Status for '$env_name':"
    echo "  Vault:      $([ "$vault_exists" = true ] && echo "✓ Configured" || echo "✗ Not configured")"
    echo "  Git Remote: $([ "$git_exists" = true ] && echo "✓ Configured" || echo "✗ Not configured")"
    echo "  Auto-Mount: $([ "$keyfile_exists" = true ] && echo "✓ Configured" || echo "✗ Not configured")"
    echo "  Mounted:    $([ "$is_mounted" = true ] && echo "✓ Yes" || echo "✗ No")"
    echo ""
    
    # If everything configured and not force mode, offer choice
    if [ "$vault_exists" = true ] && ! $force_mode; then
        echo "This environment is already configured."
        echo "1) Configure missing components only"
        echo "2) Reconfigure everything (--force)"
        echo "3) Exit"
        echo -n "Choice [1]: "
        read -r choice
        case "${choice:-1}" in
            2) force_mode=true ;;
            3) return 0 ;;
            *) ;; # Continue with partial setup
        esac
        echo ""
    fi
    
    # Step 1: Environment directory
    if [[ ! -d "$HOME/notes/$env_name" ]]; then
        echo "➡️  Creating environment directory..."
        mkdir -p "$HOME/notes/$env_name"
        note_env_switch "$env_name" &>/dev/null
        echo "✅ Environment directory created"
        echo ""
    fi
    
    # Step 2: Vault initialization
    if [ "$vault_exists" = false ] || $force_mode; then
        echo "➡️  Step 2/5: Initializing Encryption Vault..."
        if [ "$vault_exists" = true ]; then
            echo "⚠️  Vault already exists. This will reinitialize it."
            echo -n "Continue? [y/N]: "
            read -r confirm
            [[ ! "$confirm" =~ ^[Yy]$ ]] && { echo "Skipping."; vault_exists=true; } || {
                echo "You will be asked to create a PASSWORD for this vault."
                echo "⚠️  SAVE THE MASTER KEY shown after this step!"
                note_secure_init "$env_name"
                vault_exists=true
            }
        else
            echo "You will be asked to create a PASSWORD for this vault."
            echo "⚠️  SAVE THE MASTER KEY shown after this step!"
            note_secure_init "$env_name"
            vault_exists=true
        fi
        echo ""
    else
        echo "✓ Vault already initialized, skipping."
        echo ""
    fi
    
    # Step 3: Mount vault
    if [ "$is_mounted" = false ]; then
        echo "➡️  Step 3/5: Mounting Vault..."
        if ! note_secure_mount "$env_name"; then
            echo "❌ Mounting failed. Aborting wizard."
            return 1
        fi
        echo "✅ Vault mounted to ~/notes/$env_name"
        echo ""
    else
        echo "✓ Vault already mounted, skipping."
        echo ""
    fi
    
    # Step 4: Git setup
    if [ "$git_exists" = false ] || $force_mode; then
        echo "➡️  Step 4/5: Git Synchronization (Optional)"
        if [ "$git_exists" = true ]; then
            local current_url=$(cd "$HOME/.notes-encrypted/$env_name" && git remote get-url origin 2>/dev/null)
            echo "Current remote: $current_url"
            echo -n "Update remote URL? [y/N]: "
            read -r update_git
            if [[ "$update_git" =~ ^[Yy]$ ]]; then
                echo -n "New remote URL: "
                read -r git_url
                [[ -n "$git_url" ]] && note_secure_git_setup "$env_name" "$git_url"
            fi
        else
            echo "Link this vault to a remote Git repository?"
            echo -n "Remote URL (leave empty to skip): "
            read -r git_url
            [[ -n "$git_url" ]] && note_secure_git_setup "$env_name" "$git_url" || echo "Skipping Git setup."
        fi
        echo ""
    else
        echo "✓ Git already configured, skipping."
        echo ""
    fi
    
    # Step 5: Auto-mount keyfile
    if [ "$keyfile_exists" = false ] || $force_mode; then
        echo "➡️  Step 5/5: Auto-Mount Configuration (Optional)"
        if [ "$keyfile_exists" = true ]; then
            echo "⚠️  Keyfile already exists at ~/.config/notat/keys/${env_name}.key"
            echo -n "Regenerate keyfile? [y/N]: "
            read -r regen
            [[ ! "$regen" =~ ^[Yy]$ ]] && echo "Skipping." || {
                rm -f "$HOME/.config/notat/keys/${env_name}.key"
                note_secure_key_gen "$env_name"
                _verify_auto_mount "$env_name"
            }
        else
            echo "Enable Passwordless Auto-Mount?"
            echo "This creates a keyfile protected by your user permissions."
            echo -n "Enable? [y/N]: "
            read -r auto_choice
            if [[ "$auto_choice" =~ ^[Yy]$ ]]; then
                note_secure_key_gen "$env_name"
                _verify_auto_mount "$env_name"
            else
                echo "Skipping Auto-Mount."
            fi
        fi
        echo ""
    else
        echo "✓ Auto-mount already configured, skipping."
        echo ""
    fi
    
    echo "🎉 Setup Complete!"
    echo "Environment: $env_name"
    echo "Run 'notat secure publish' to sync changes."
    echo "To update your shell: source \"\$NOTES_SYSTEM_DIR/config.zsh\""
}

# Helper for auto-mount verification
_verify_auto_mount() {
    local env="$1"
    echo ""
    echo "🧐 Verifying Auto-Mount..."
    note_secure_unmount "$env" &>/dev/null
    if note_secure_mount "$env" --auto; then
        echo "✅ Auto-Mount Verified!"
        echo "Add to .zshrc: notat secure mount $env --auto"
    else
        echo "❌ Auto-Mount verification failed."
        echo "Check permissions: ~/.config/notat/keys/${env}.key"
    fi
}
