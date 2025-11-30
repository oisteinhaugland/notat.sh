# Notat.sh

A simple, terminal-based, keyboard-centric notetaking system for Zsh and Bash.

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
    - [Neovim Integration](#neovim-integration)
- [Installation](#installation)
    - [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage Cheat Sheet](#usage-cheat-sheet)
- [Neovim Integration](#neovim-integration-1)

## Motivation

### Problems
We all know the feeling. You have a thought, an idea, or a task, and you want to write it down. But where?
- "Should this go in my 'Work' folder or 'Projects'?"
- "Do I need to make a new tag for this?"
- "What should I name this file so I can find it later?"

By the time you've answered these questions, the moment is gone. The friction of *organizing* gets in the way of *doing*.

### Solutions
**Notat.sh** is built to be your "second brain" that doesn't get in your way.
- **Capture First**: Just get it down. Use `nt` (New Thought) or `nd` (New Daily) to capture instantly.
- **Trust Search**: Don't worry about where it goes. With powerful search tools built-in, you can always find it later.
- **Stay in Flow**: Keep your hands on the keyboard and your mind on your work. Structure can wait.

## Features

### Terminal Workflow

**Notat.sh** is designed to be used entirely from your terminal using short aliases.

### Powerful search
Find everything, quickly. The system uses `ripgrep` (rg) for lightning-fast text search across all your notes, and `fzf` for fuzzy finding files by name. Whether you remember a keyword or just a filename, you can find it in milliseconds.

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

1.  **Clone the Repo**:
    ```bash
    git clone https://github.com/yourusername/notat.sh.git ~/.notat.sh
    ```
    *(Or just copy the folder to your home directory)*

2.  **Enable it**:
    Add this line to your shell configuration file (`~/.zshrc` for Zsh, `~/.bashrc` for Bash):
    ```bash
    source ~/.notat.sh/init.zsh
    ```

3.  **Install Dependencies**:
    You need these three tools installed for the magic to work:
    - `ripgrep` (rg): For lightning fast search.
    - `fzf`: For the interactive fuzzy finder.
    - `bat`: For file previews.

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
- `sab`: Search **Backlog** (`,`).
- `saf`: Search **Action Files**.
- `sq`: Search **Questions** (`?`).
- `sj`: Search **Journals**.
- `sp`: Search **People**.
- `sr`: Search **Resources**.

### Pick (File Finder)
- `pd`: Pick Daily note.
- `pt`: Pick Thought note.
- `pa`: Pick Action note.
- `pj`: Pick Journal.
- `pp`: Pick Person.
- `pr`: Pick Resource.

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

## Neovim Integration

Add this to your `init.lua`:

```lua
local notes = require('notes_system.nvim_integration')
notes.setup()
```

### Keybindings
- `<leader>o`: **Smart Open**.
    - On an action line (`. Task`): Creates/Opens the action note.
    - On a source link (`@ Source: file:line`): Opens the source file.
- `<leader>x`: Toggle Open (`.`) <-> Closed (`x`).
- `<leader>a`: Toggle Open (`.`) <-> Active (`=`).
- `<leader>,`: Toggle Open (`.`) <-> Parked (`,`).
- `<leader>q`: Toggle Open (`.`) <-> Question (`?`).
- `<leader>-`: **Archive Note**. Moves current note to `archive/[type]/`.
