# Intended for zsh
# Secure Storage (Encryption) for Notat.sh using gocryptfs

# Helper to check for gocryptfs
_check_gocryptfs() {
    if ! command -v gocryptfs &> /dev/null; then
        echo "Error: gocryptfs is not installed."
        echo "Please install it via brew or your package manager."
        return 1
    fi
}

# Help for secure commands
note_secure_help() {
    cat <<EOF
Usage: notat secure <command> [args]

Commands:
  init [env]                Initialize encrypted vault
  mount [env] [--auto]      Mount encrypted vault
  unmount [env]             Unmount encrypted vault
  publish [env] [remote]    Publish (git push) encrypted vault
  git-setup <env> <url>     Configure git remote for vault
  recover <env> <url>       Clone existing encrypted vault
  passwd [env]              Change vault password
  key-gen [env]             Generate keyfile for auto-mount

Examples:
  notat secure init personal
  notat secure mount personal --auto
  notat secure publish personal
  notat secure git-setup work git@github.com:user/vault.git
EOF
}

# Initialize a new secure vault
note_secure_init() {
    _check_gocryptfs || return 1
    local name="${1:-$(note_env_current)}"
    
    local plain_dir="$HOME/notes/$name"
    local cipher_dir="$HOME/.notes-encrypted/$name"
    
    if [[ -d "$cipher_dir" ]]; then
        if [[ "$(ls -A "$cipher_dir")" ]]; then
            echo "Error: Encrypted directory '$cipher_dir' already exists and is not empty."
            return 1
        fi
    fi
    
    mkdir -p "$cipher_dir"
    mkdir -p "$plain_dir"
    
    echo "Initializing encrypted vault at: $cipher_dir"
    gocryptfs -init "$cipher_dir"
    
    echo ""
    echo "Vault initialized."
    echo "To mount, run: notat secure mount $name"
}

# Mount the vault
# Usage: notat secure mount <name> [--auto]
note_secure_mount() {
    _check_gocryptfs || return 1
    local name="${1:-$(note_env_current)}"
    local mode=""
    
    # Simple argument parsing
    if [[ "$2" == "--auto" ]]; then
        mode="auto"
    fi
    
    local plain_dir="$HOME/notes/$name"
    local cipher_dir="$HOME/.notes-encrypted/$name"
    local keyfile="$HOME/.config/notat/keys/${name}.key"
    
    if [[ ! -d "$cipher_dir" ]]; then
        echo "Error: Encrypted directory '$cipher_dir' does not exist."
        echo "Run 'notat secure init $name' first (or recover from git)."
        return 1
    fi
    
    mkdir -p "$plain_dir"
    
    # Check if already mounted
    if mount | grep -q "$plain_dir"; then
        # Silent in auto mode when already mounted, verbose otherwise
        [[ "$mode" != "auto" ]] && echo "Already mounted: $plain_dir"
        return 0
    fi
    
    echo "Mounting $cipher_dir -> $plain_dir"
    
    if [[ "$mode" == "auto" ]]; then
        if [[ -f "$keyfile" ]]; then
            # Verify permissions (must be 600)
             # Stat format differs on Linux/macOS, checking readable by others is safer
            if ls -l "$keyfile" | grep -q "^-rw-------"; then
                 # Use -nonempty due to pre-created folders
                gocryptfs -nonempty -passfile "$keyfile" "$cipher_dir" "$plain_dir"
            else
                echo "Warning: Keyfile permissions are too open. Should be 600 (-rw-------)."
                echo "Run: chmod 600 $keyfile"
                echo "Falling back to interactive password."
                gocryptfs -nonempty "$cipher_dir" "$plain_dir"
            fi
        else
            echo "Keyfile not found at: $keyfile"
            echo "Falling back to interactive password."
            gocryptfs -nonempty "$cipher_dir" "$plain_dir"
        fi
    else
        gocryptfs -nonempty "$cipher_dir" "$plain_dir"
    fi
}

# Unmount the vault
note_secure_unmount() {
    local name="${1:-$(note_env_current)}"
    
    local plain_dir="$HOME/notes/$name"
    
    if mount | grep -q "$plain_dir"; then
        echo "Unmounting $plain_dir..."
        if command -v fusermount &> /dev/null; then
            fusermount -u "$plain_dir"
        else
            umount "$plain_dir"
        fi
    else
        echo "Not mounted: $plain_dir"
    fi
}

# Generate Keyfile for Auto-Mount
note_secure_key_gen() {
    local name="${1:-$(note_env_current)}"
    local key_dir="$HOME/.config/notat/keys"
    local keyfile="$key_dir/${name}.key"
    
    mkdir -p "$key_dir"
    
    if [[ -f "$keyfile" ]]; then
        echo "Keyfile already exists: $keyfile"
        return 1
    fi
    
    echo "Creating Auto-Mount Keyfile for '$name'"
    echo "Warning: This file will contain your password in plaintext."
    echo "It will be readable ONLY by your user."
    echo ""
    echo -n "Enter Vault Password: "
    read -rs password
    echo ""
    
    echo "$password" > "$keyfile"
    chmod 600 "$keyfile"
    
    echo "Keyfile created at: $keyfile"
    echo "You can now use: notat secure mount $name --auto"
}

# Change Vault Password
note_secure_passwd() {
    _check_gocryptfs || return 1
    local name="${1:-$(note_env_current)}"
    local cipher_dir="$HOME/.notes-encrypted/$name"
    
    if [[ ! -d "$cipher_dir" ]]; then
        echo "Error: Vault '$name' (encrypted) does not exist."
        return 1
    fi
    
    gocryptfs -passwd "$cipher_dir"
}

# Publish (Git Push Encrypted Repo)
note_secure_publish() {
    local name="${1:-$(note_env_current)}"
    local remote="${2:-origin}"
    local msg="Sync $(date '+%Y-%m-%d %H:%M:%S')"
    
    local cipher_dir="$HOME/.notes-encrypted/$name"
    
    if [[ ! -d "$cipher_dir" ]]; then
        echo "Error: Encrypted directory '$cipher_dir' does not exist."
        return 1
    fi
    
    echo "🚀 Publishing encrypted notes from: $cipher_dir"
    (cd "$cipher_dir" && \
     git add . && \
     git commit -m "$msg" && \
     git push "$remote")
}

# Setup Git Remote for Encrypted Vault
note_secure_git_setup() {
    local name="$1"
    local url="$2"
    
    if [[ -z "$name" || -z "$url" ]]; then
        echo "Usage: notat secure git-setup <env> <git_url>"
        echo ""
        echo "Example URLs:"
        echo "  git@github.com:username/repo.git"
        echo "  https://github.com/username/repo.git"
        return 1
    fi
    
    # Validate URL format
    if [[ ! "$url" =~ ^(git@|https://) ]]; then
        echo "⚠️  Warning: URL doesn't look like a standard git URL."
        echo "Expected format: git@... or https://..."
        echo -n "Continue anyway? [y/N]: "
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted."
            return 1
        fi
    fi
    
    local cipher_dir="$HOME/.notes-encrypted/$name"
    
    if [[ ! -d "$cipher_dir" ]]; then
        echo "Error: Vault directory '$cipher_dir' does not exist. Run 'secure init' first."
        return 1
    fi
    
    echo "Setting up Git in: $cipher_dir"
    cd "$cipher_dir"
    
    if [[ ! -d ".git" ]]; then
        git init
        git branch -M main
    fi
    
    # Check if remote exists
    if git remote | grep -q "origin"; then
        echo "Remote 'origin' already exists. Updating URL..."
        git remote set-url origin "$url"
    else
        git remote add origin "$url"
    fi
    
    echo ""
    echo "Stubbing Local Git Identity (Optional)"
    echo "Useful if you want to use different emails for Work vs Personal."
    echo "Press Enter to skip (use global config)."
    
    echo -n "Git Name [Skip]: "
    read -r git_name
    if [[ -n "$git_name" ]]; then
        git config user.name "$git_name"
    fi
    
    echo -n "Git Email [Skip]: "
    read -r git_email
    if [[ -n "$git_email" ]]; then
        git config user.email "$git_email"
    fi
    
    echo ""
    echo "Setting up upstream tracking..."
    git add .
    git commit --allow-empty -m "Initial setup"
    
    if git push -u origin main; then
        echo "✅ Git Setup Complete. Upstream tracking configured."
    else
        echo "⚠️  Push failed. You may need to:"
        echo "  - Create the repository on the remote"
        echo "  - Check your authentication credentials"
        echo "Run 'notat secure publish $name' after fixing."
    fi
}


# Recover (Git Clone Encrypted Repo)
note_secure_recover() {
    local name="$1"
    local url="$2"
    
    if [[ -z "$name" || -z "$url" ]]; then
        echo "Usage: notat secure recover <name> <git_url>"
        return 1
    fi
    
    local cipher_dir="$HOME/.notes-encrypted/$name"
    
    if [[ -d "$cipher_dir" ]]; then
        # Check if it's a git repo
        if [[ -d "$cipher_dir/.git" ]]; then
             echo "Directory exists and is a git repo. Attempting pull..."
             (cd "$cipher_dir" && git pull)
             echo "Pull complete. Run 'notat secure mount $name' to access."
             return 0
        elif [[ -f "$cipher_dir/gocryptfs.conf" ]]; then
             echo "Directory exists and looks like a valid vault."
             echo "Run 'notat secure mount $name' to access."
             return 0
        else
            echo "Error: Directory '$cipher_dir' exists but is not empty or a git repo."
            return 1
        fi
    fi
    
    echo "📥 Recovering (cloning) into: $cipher_dir"
    git clone "$url" "$cipher_dir"
    
    echo "Done. You can now mount it with: notat secure mount $name"
}
