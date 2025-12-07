# Notat.sh

A terminal-based note-taking system optimized for speed and flow.

> **New here?** Start with the [Quick Start Guide](QUICKSTART.md) for a 5-minute introduction.

> **Note**: This project is a work in progress. Features and documentation may change.

## Table of Contents
- [Why Notat.sh](#why-notatsh)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Security & Environments](#security--environments)
- [Command Reference](#command-reference)
- [Neovim Integration](#neovim-integration)
- [Documentation](#documentation)

## Why Notat.sh

Capture friction - Naming and filing decisions kill momentum

Retrieval failure - Can't find what you wrote

Context switching - Leaving your workflow to take notes

No thinking space - Nowhere to work through problems

Task overwhelm - The management overhead exceeded the actual work

## Features

### Terminal-First Workflow
Designed for keyboard-driven speed. **All commands are 2-3 characters.**

### Instant Search
Find anything in milliseconds:
- **Full-text search** with `ripgrep` (search within note types)
- **File picker** with `fd` + `fzf` for finding by filename
- **Live previews** with syntax highlighting

### Distributed Task Management
Track tasks across *all* your notes with simple markers:

| Marker | Meaning | Example |
|--------|---------|---------|
| `. ` | Open | `. Call dentist` |
| `= ` | Active (doing now) | `= Write proposal` |
| `x ` | Done | `x Finished taxes` |
| `, ` | Parked (later) | `, Read that book` |
| `> ` | Waiting/Blocked | `> Waiting for feedback` |
| `? ` | Question | `? What was the decision?` |

Toggle states with Neovim keybindings or just edit the marker manually.

### Zero Organization Required
Notes auto-organize by type:
- **Daily**: Your daily inbox (`nd`)
- **Thoughts**: Quick timestamped ideas (`nt`)
- **Actions**: Dedicated task notes (`na`)
- **Resources**: Knowledge base (`nr`)
- **Journals**: Long-running topic logs (`nj`)
- **People**: Contact & interaction logs (`np`)

### Built-in Encryption
Secure your notes with `gocryptfs`:
- End-to-end encrypted vaults
- Multiple environments (work/personal)
- Git sync for encrypted backups
- Auto-mount with keyfiles

### Unified CLI
A comprehensive `notat` command for system management:
- **Setup wizard**: `notat setup` - Interactive environment creation
- **Environment switching**: `notat env switch work/personal`
- **Security management**: `notat secure mount/unmount/publish`
- **Health checks**: `notat doctor` - Verify dependencies and configuration
- **Statistics**: `notat stats` - View notes and task metrics
- **Auto-configured aliases**: 2-3 letter shortcuts automatically added to your shell (`nd`, `nt`, `sa`, `ra`, etc.)

### Customizable Themes
Pick your preview theme: `notat theme`

## Installation

### Requirements
- **Zsh** or **Bash**
- Required: `ripgrep`, `fzf`, `bat`, `fd`, `git`
- Optional: `gocryptfs` (for encryption), `neovim` (for integration)

### Install

```bash
git clone https://github.com/yourusername/notat.sh.git
cd notat.sh
./install.sh
```

The installer will:
1. Check dependencies
2. Link the system to `~/.config/notat.sh`
3. Add initialization to your shell config
4. Optionally set up Neovim integration

Restart your terminal when done.

## Quick Start

### 1. Initial Setup

Run the setup wizard:
```bash
notat setup
```

This creates your first environment and optionally configures encryption and Git sync.

> **Tip**: Run `notat setup --force` to reconfigure an existing environment.

### 2. Your First Notes

```bash
nd          # Open today's daily note (your inbox)
nt          # Create a timestamped thought
```

### 3. Find Your Work

```bash
sa          # Search all active tasks
st meeting  # Search thoughts for "meeting"
oa          # Open the first active (=) task
```

### 4. The Grammar

Commands follow `[VERB][SUBJECT]`:

**Common verbs:**
- `n` = New
- `s` = Search (within type)
- `p` = Pick (file finder)
- `o` = Open
- `r` = Review (interactive loop)

**Subjects:**
- `d` = Daily
- `t` = Thoughts
- `a` = Actions
- `r` = Resources
- `j` = Journals
- `p` = People

**Examples:**
- `nd` = New Daily
- `st` = Search Thoughts
- `ra` = Review Actions
- `pp` = Pick Person file

## Security & Environments

### Environments

Separate your work and personal notes:

```bash
notat env list              # Show all environments
notat env switch work       # Switch to 'work'
notat stats personal        # View stats for 'personal'
```

### Encryption

Protect sensitive notes with `gocryptfs`:

```bash
notat secure init personal         # Create encrypted vault
notat secure mount personal        # Mount vault
notat secure publish personal      # Git push encrypted notes
```

#### Auto-Mount
Generate a keyfile for passwordless mounting:

```bash
notat setup personal   # Wizard includes auto-mount setup
```

Then add to your `.zshrc`:
```bash
notat secure mount personal --auto
```

#### Git Sync
Sync encrypted vaults to GitHub/GitLab:

```bash
notat secure git-setup personal git@github.com:user/vault.git
notat secure publish personal     # Push changes
```

The vault is encrypted before it leaves your machine. Only you can decrypt it.

## Command Reference

### Core Commands

```bash
notat new <type> [name]      # Create note
notat search <type> [query]  # Search content
notat pick <type>            # Find file
notat review <type>          # Interactive loop
```

### Environment & Security

```bash
notat env list               # List environments
notat env switch <name>      # Switch environment

notat secure init [env]      # Initialize encrypted vault
notat secure mount [env]     # Mount vault
notat secure unmount [env]   # Unmount vault
notat secure publish [env]   # Git push vault
notat secure git-setup <env> <url>  # Configure git remote
```

### System

```bash
notat theme                  # Select preview theme
notat stats [env]            # Show statistics
notat doctor                 # Health check
notat backup [env]           # Quick publish (alias)
notat --help                 # Show help
```

### Shell Aliases

After installation, these aliases are available:

**Create:**
- `nd`, `nt`, `na`, `nr`, `nj`, `np`

**Search:**
- `sd`, `st`, `sa`, `sr`, `sj`, `sp`
- `sa` - Active tasks only
- `saa` - All actions (including indented)
- `sq` - Questions

**Pick (file finder):**
- `pd`, `pt`, `pa`, `pr`, `pj`, `pp`

**Review:**
- `rd`, `rt`, `ra`, `rr`, `rj`, `rp`

**Open:**
- `od` - Open today's daily
- `oa` - Open first active task

## Neovim Integration

The installer can set this up automatically, or you can do it manually.

### Manual Setup

1. Symlink the integration:
```bash
ln -s ~/.config/notat.sh/nvim_integration.lua ~/.config/nvim/lua/notat.lua
```

2. Create `~/.config/nvim/lua/notat_config.lua`:
```lua
require('notat').setup({
    notes_dir = os.getenv('NOTES_BASE_DIR'),
    actions_dir = os.getenv('NOTES_ACTIONS_DIR'),
})
```

3. Add to your `init.lua`:
```lua
require('notat_config')
```

### Keybindings

| Key | Action |
|-----|--------|
| `<leader>o` | Smart open (creates action, opens source, or follows link) |
| `<leader>x` | Toggle Open ↔ Done |
| `<leader>a` | Toggle Open ↔ Active |
| `<leader>,` | Toggle Open ↔ Parked |
| `<leader>q` | Toggle Open ↔ Question |
| `<leader>A` | Archive current note |

## Configuration

Edit `~/.config/notat.sh/config.zsh`:

```bash
NOTES_BASE_DIR="$HOME/notes"                    # Notes location
NOTES_DAILY_DATE_FORMAT="%Y-%m-%d"              # Daily note format
NOTES_FZF_OPTS="--height=80% --border=rounded"  # FZF options
```

## Documentation

- **[Quick Start Guide](QUICKSTART.md)** - 5-minute introduction for beginners
- **[System Description](docs/system-description.md)** - Design philosophy and technical details
- **[Test Suite Documentation](tests/README.md)** - Test suite documentation

## Health Check

Verify your installation:

```bash
notat doctor
```

This checks:
- All dependencies (required and optional)
- Environment variables
- Neovim integration
- System configuration

## Troubleshooting

**"Command not found: notat"**
- Run `source ~/.zshrc` or restart your terminal

**"Vault already mounted"** (when using `--auto`)
- This is normal on subsequent shells. Silent by design.

**Preview not showing**
- Check `bat` is installed: `which bat`
- Try changing theme: `notat theme`

**Git push fails**
- Ensure remote repository exists
- Check authentication: `ssh -T git@github.com`

## Contributing

Contributions welcome! Please read the [system description](docs/system-description.md) to understand the design philosophy first.

## License

MIT
