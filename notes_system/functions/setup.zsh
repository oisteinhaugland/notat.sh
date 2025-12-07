# Intended for zsh
# Onboarding Wizard for Notat.sh

note_setup() {
    local env_name="$1"
    
    echo "Welcome to the Notat Setup Wizard! 🧙‍♂️"
    echo "-------------------------------------"
    echo "This wizard will help you set up a new environment with encryption and sync."
    echo ""
    
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
    
    echo "➡️  Step 1/5: Setting up environment '$env_name'..."
    # Reuse env switch logic (handles directory creation)
    # We mock 'y' for directory creation
    echo "y" | note_env_switch "$env_name" > /dev/null
    echo "✅ Environment '$env_name' is ready."
    echo ""
    
    # 3. Secure Init
    echo "➡️  Step 2/5: Initializing Encryption Vault..."
    local cipher_dir="$HOME/.notes-encrypted/$env_name"
    if [[ -d "$cipher_dir" && "$(ls -A "$cipher_dir")" ]]; then
        echo "encrypted vault already exists at $cipher_dir."
        echo "Skipping initialization."
    else
        echo "You will now be asked to create a PASSWORD for this vault."
        echo "⚠️  SAVE THE MASTER KEY shown after this step!"
        note_secure_init "$env_name"
    fi
    echo ""
    
    # 4. Mount
    echo "➡️  Step 3/5: Mounting Vault..."
    echo "Please enter your password to verify everything works."
    if ! note_secure_mount "$env_name"; then
        echo "❌ Mounting failed. Aborting wizard."
        return 1
    fi
    echo "✅ Vault mounted to ~/notes/$env_name"
    echo ""
    
    # 5. Git Setup
    echo "➡️  Step 4/5: Git Synchronization (Optional)"
    echo "Do you want to link this vault to a remote Git repository?"
    echo -n "Remote URL (leave empty to skip): "
    read -r git_url
    
    if [[ -n "$git_url" ]]; then
        note_secure_git_setup "$env_name" "$git_url"
    else
        echo "Skipping Git setup."
    fi
    echo ""
    
    # 6. Auto-Mount (Keyfile)
    echo "➡️  Step 5/5: Auto-Mount Configuration (Optional)"
    echo "Do you want to enable Passwordless Auto-Mount?"
    echo "This creates a keyfile protected by your user permissions."
    echo "Useful for startup scripts."
    echo -n "Enable Auto-Mount? [y/N]: "
    read -r auto_choice
    
    if [[ "$auto_choice" =~ ^[Yy]$ ]]; then
        note_secure_key_gen "$env_name"
        
        echo ""
        echo "🧐 Verifying Auto-Mount..."
        echo "We will now Unmount and attempt to Automount to prove it works."
        note_secure_unmount "$env_name"
        if note_secure_mount "$env_name" --auto; then
            echo "✅ Auto-Mount Verified!"
            echo "To mount automatically on startup, add this to your .zshrc:"
            echo "notat secure mount $env_name --auto"
        else
            echo "❌ Warning: Auto-Mount failed verification."
            echo "You may need to check permissions on ~/.config/notat/keys/$env_name.key"
        fi
    else
        echo "Skipping Auto-Mount."
    fi
    
    echo ""
    echo "🎉 Setup Complete!"
    echo "You are now in the '$env_name' environment."
    echo "Run 'notat secure publish' to sync changes."
    echo "Source your shell to update the prompt: source \"\$NOTES_SYSTEM_DIR/config.zsh\""
}
