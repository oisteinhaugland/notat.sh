# Notat.sh System Description

**Notat.sh** is a terminal-centric, file-based note-taking system designed for speed, simplicity, and flow. It leverages standard Unix tools (`rg`, `fd`, `fzf`, `bat`) to provide a powerful, low-friction interface for capturing and retrieving information.

## Core Philosophy

1.  **Capture First**: Eliminate friction. Capture thoughts and tasks instantly without worrying about organization.
2.  **Trust Search**: Retrieval is instantaneous. Rely on powerful full-text search rather than rigid hierarchies.
3.  **Plain Text**: All data is stored in standard Markdown files, ensuring longevity and portability.

## System Architecture

The system is built as a collection of Zsh/Bash functions and aliases that operate on a defined directory structure.

### Directory Structure
- `daily/`: Daily logs (e.g., `2025-12-05.md`). The default inbox.
- `thoughts/`: Atomic, timestamped notes for quick ideas.
- `actions/`: Dedicated files for complex tasks or projects.
- `journals/`: Long-running logs for specific topics.
- `people/`: Contact logs and interaction history.
- `resources/`: Static knowledge base and reference material.
- `archive/`: Storage for completed or stale notes.

## The Grammar

Interacting with the system follows a consistent `[VERB][SUBJECT]` pattern (mostly 2-letter aliases).

### Verbs
- **n (New)**: Create a new note.
- **s (Search)**: Full-text search within note contents (uses `ripgrep`).
- **f (Find)**: Fuzzy find files by filename (uses `fd`).
- **r (Review)**: Interactive loop for processing notes (search -> edit -> search).
- **o (Open)**: Open a specific, predetermined note (e.g., today's daily).
- **p (Pick)**: Select a single file to open (similar to Find).

### Subjects
- **d**: Daily
- **t**: Thoughts
- **a**: Actions
- **j**: Journals
- **p**: People
- **r**: Resources

### Examples
- `nd`: New Daily (Open today's note)
- `st`: Search Thoughts
- `ra`: Review Actions
- `fp`: Find Person (file)

## Key Capabilities

### 1. Unified Search & Preview
The system features a centralized, robust preview engine powered by `fzf` and `bat`.
- **Live Previews**: See file content immediately as you search.
- **Syntax Highlighting**: Code and markdown are beautifully highlighted.
- **Smart Scrolling**: The preview window automatically scrolls to the matching line in search results.
- **Deep Linking**: Opening a search result jumps directly to the specific line in the editor.

### 2. Task Management
Tasks are tracked across *all* notes using simple markdown syntax.
- **Markers**:
    - `. ` Open
    - `= ` Active
    - `, ` Parked/Backlog
    - `x ` Done
    - `> ` Waiting
    - `? ` Question
- **Workflow**:
    - `sa`: Search active tasks (Open, Active, Waiting, Question).
    - `oa`: Open the first "Active" (`=`) task immediately.

### 3. Theme System
The visual appearance of previews is customizable.
- **CLI Management**: Use `notat theme` to interactively preview and select themes.
- **Persistence**: Selections are saved to `config.zsh`.
- **High Contrast**: Defaults to "Visual Studio Dark+" for optimal visibility of highlighted lines.

### 4. Neovim Integration
A dedicated Lua module provides seamless integration within Neovim.
- **Smart Open (`<leader>o`)**:
    - Opens the file under the cursor (if it's a file path).
    - Jumps to the source of an action (if it has a `@ Source:` tag).
    - Creates a new action note from a task line.
- **State Toggling**: Quickly toggle task states (Open <-> Done, Active, Parked).

## User Experience & Design Ethos

This section details the intended user experience, serving as a guide for future feature development. The goal is to maintain the "spirit" of Notat.sh.

### 1. Speed as a Feature
The system is built on the premise that latency kills thought.
- **Interaction Time**: Operations should feel instantaneous (< 50ms).
- **Keystrokes**: Commands are optimized for brevity (2-3 characters).
- **No Loading Screens**: Everything is local and text-based.

### 2. The "Capture" Flow
*Goal: Zero friction between thought and storage.*
- **Scenario**: A user has an idea while coding.
- **Action**: `nt` -> Type idea -> Save -> Quit.
- **Result**: The user is back to coding in seconds. The idea is safe, timestamped, and searchable.
- **Design Principle**: Do not ask the user to categorize *before* capturing.

### 3. The "Retrieval" Flow
*Goal: Trust in the system.*
- **Scenario**: "I wrote something about 'docker' last week."
- **Action**: `st docker` (Search Thoughts).
- **Feedback**: Immediate list of results with live preview.
- **Result**: User sees the context immediately without opening files.
- **Design Principle**: Search is the primary navigation mechanism. Directories are implementation details.

### 4. The "Action" Loop
*Goal: Fluid task management.*
- **Scenario**: Reviewing what to do next.
- **Action**: `sa` (Search Active).
- **Feedback**: A consolidated view of all open loops across the entire system.
- **Refinement**: User can edit lines in place or open the file to elaborate.
- **Design Principle**: Tasks live where they are born (in context), but are viewed centrally.

### 5. Visual Hierarchy & Feedback
- **Previews**: The preview window is not just for looking; it's for *orienting*. The highlighted line and surrounding context allow the user to make decisions (open vs. skip) without entering the file.
- **Themes**: High-contrast themes are not aesthetic choices; they are functional requirements for rapid scanning.

## CLI Reference (`notat`)

The `notat` command provides a unified entry point for all system functions.

```bash
notat new [type] [name]   # Create notes
notat search [type]       # Search content
notat pick [type]         # Find files
notat review [type]       # Interactive review loop
notat theme               # Change preview theme
notat health              # System health check
```

## Dependencies
- **ripgrep (`rg`)**: Fast text search.
- **fd-find (`fd`)**: Fast file finding.
- **fzf**: Fuzzy finder interface.
- **bat**: Syntax highlighting and preview rendering.
