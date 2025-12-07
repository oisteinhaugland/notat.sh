# Notat.sh

A simple, terminal-based, note-taking system.

## Table of Contents
- [Motivation](#motivation)
    - [Problems](#problems)
    - [Solutions](#solutions)
- [Features](#features)
    - [Terminal Workflow](#terminal-workflow)
    - [Powerful search](#powerful-search)
    - [Task System](#task-system)
    - [Automatic organization](#automatic-organization)
    - [Simple Grammar](#simple-grammar)

- [Installation](#installation)
    - [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage Cheat Sheet](#usage-cheat-sheet)
- [Neovim Integration](#neovim-integration-1)

## Motivation

### Problems

Thoughts, ideas, anything noteworthy...

    - Where do you put it?
    - What should you name it?
    - How will you find it again?
   
Tasks...

    - what was i working on again?
    - where can i think this through?
    - where is all the information i need?
    - do i have any unanswered questions?

This friction gets in the way of writing, thinking and doing.


### Solutions

- **Capture First**: Just get it down. Use `nt` (New Thought) or `nd` (New Daily) to capture instantly.
- **Trust Search**: Don't worry about where it goes. With powerful search tools built-in, you can always find it later.
- **Stay in Flow**: Keep your hands on the keyboard and your mind on your work. 

## Features

### Terminal Workflow

**Notat.sh** is designed to be used entirely from your terminal using short aliases.

### Powerful search
Find everything, quickly. 

The system uses `ripgrep` (rg) for lightning-fast text search across all your notes, and `fd-find` (fd) with  `fzf` for fuzzy finding files by name.

Whether you remember a keyword or just a filename, you can find it in milliseconds.

### Task System

Turn any line into a task by starting it with a symbol. The system tracks these across all your notes.

- `. ` : **Open** (Something to do)
- `= ` : **Active** (Working on it right now)
- `, ` : **Parked** (Backlog/Later)
- `x ` : **Closed** (Done)
- `> ` : **Waiting** (Blocked/Waiting for someone)
- `? ` : **Question** (Something to investigate)

### Automatic organization

Notes are organized for you.

The system provides six opinionated types to keep your notes separated by intent:

- **Daily**: Your daily inbox. Write whatever is on your mind for the day.
- **Thoughts**: Quick ideas, sparks, or literally anything that crosses your mind.
- **Actions**:  For action that demand their own note.

- **Resources**: Static knowledge and reference material. This is where your knowledge ends up.
- **Journals**: Long-running logs for specific topics (e.g., Diary, Work, Training).
- **People**: Contact details and interaction logs (think crm-lite).

All notes can be archived.

### Simple Grammar

Commands in **Notat.sh** follows a `[VERB][SUBJECT]` structure.

#### Verbs
- s, search (text)
- f, find (file)
- r, review (looped search)
- o, open (predetermined file)
- n, new (create file)

#### Subjects
Common:
- d, daily
- t, thoughts
- a, actions

Support:
- r, resources
- A, archive
- p, people
- j, journals

### Neovim Integration

Toggle tasks status, archive notes, and create action notes, open links with keyboard shortcuts.

## Installation

1.  **Run the Installer**:
    ```bash
    ./install.sh
    ```
    This script will:
    - Check for dependencies (`rg`, `fzf`, `bat`, `fd`).
    - Symlink the system to `~/.notat.sh` (or copy if you prefer).
    - Add the source line to your shell config.

2.  **Manual Installation** (Alternative):
    - Clone: `git clone https://github.com/yourusername/notat.sh.git ~/.notat.sh`
    - Enable: Add `source ~/.notat.sh/init.zsh` to `~/.zshrc` or `~/.bashrc`.
    - Deps: Install `ripgrep`, `fzf`, `bat`, and `fd`.

### Getting Started
1.  **Start your day**: `od` (Open Daily).
2.  **Have an idea?**: `nt` (New Thought).
3.  **Time to work**: `sa` (Review Actions).
4.  **Need info?**: `sr` (Search Resources).

## Configuration

Edit `notes_system/config.zsh` to customize:

- `NOTES_BASE_DIR`: Where your notes are stored (default: `~/notes`).
- `NOTES_DAILY_DATE_FORMAT`: Format for daily note filenames.
- `NOTES_FZF_OPTS`: Custom flags for FZF.
- `EDITOR`: Your preferred editor (default: `vim`).

## Usage Cheat Sheet

### Creation
- `nd`: **New Daily**. Opens today's daily note.
- `nt`: **New Thought**. Creates a timestamped note.
- `na`: **New Action**. Prompts for a title.
- `nj`: **New Journal**. Prompts for a topic.
- `np`: **New Person**. Prompts for a name.
- `nr`: **New Resource**. Prompts for a title.

### Search
- `sd`: Search **Daily** notes.
- `st`: Search **Thought** notes.
- `sa`: Search **Active Actions** (top-level `.`, `=`, `>`).
- `saa`: Search **All Actions** (including indented).
- `sab`: Search **Action Backlog** (`,`).
- `saf`: Search **Action Files**.
- `sq`: Search **Questions** (`?`).
- `sj`: Search **Journals**.
- `sp`: Search **People**.
- `sr`: Search **Resources**.

### Find (File Finder)
- `fd`: Find Daily note.
- `ft`: Find Thought note.
- `fa`: Find Action note.
- `fj`: Find Journal.
- `fp`: Find Person.
- `fr`: Find Resource.

### Review (Interactive Loop)
- `rd`: Review Daily notes.
- `rt`: Review Thought notes.
- `ra`: Review Action notes.
- `rj`: Review Journal.
- `rp`: Review People.
- `rr`: Review Resource.

### Open
- `od`: Open today's daily note (same as `nd`).
- `oa`: **Open Active**. Opens the first active task (`=`).

## Health Check

Run `notat_health` to verify your installation, dependencies, and configuration.

```bash
notat_health
```

## Neovim Integration

The installer can set this up for you automatically.

To set it up manually:

1.  Symlink `notes_system/nvim_integration.lua` to `~/.config/nvim/lua/notat.lua`.
2.  Create `~/.config/nvim/lua/notat_config.lua` with:
    ```lua
    require('notat').setup({
        notes_dir = os.getenv('NOTES_BASE_DIR'),
        actions_dir = os.getenv('NOTES_ACTIONS_DIR'),
    })
    ```
3.  Add `require('notat_config')` to your `init.lua`.

> [!IMPORTANT]
> Do **NOT** source `init.lua` in your shell (bash/zsh). It is a Neovim configuration file.

### Keybindings
- `<leader>o`: **Smart Open**.
    - On an action line (`. Task`): Creates/Opens the action note.
    - On a source link (`@ Source: file:line`): Opens the source file.
- `<leader>x`: Toggle Open (`.`) <-> Closed (`x`).
- `<leader>a`: Toggle Open (`.`) <-> Active (`=`).
- `<leader>,`: Toggle Open (`.`) <-> Parked (`,`).
- `<leader>q`: Toggle Open (`.`) <-> Question (`?`).
- `<leader>A`: **Archive Note**. Moves current note to `archive/[type]/`.
