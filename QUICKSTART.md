# Notat.sh Quick Start

> **Note**: This project is a work in progress. Features and documentation may change.

Get up and running with Notat.sh in 5 minutes.

## What is Notat.sh?

A terminal-based note-taking system that helps you capture thoughts instantly and find them effortlessly. Think of it as your second brain, optimized for speed.

## Installation

```bash
git clone https://github.com/yourusername/notat.sh.git
cd notat.sh
./install.sh
```

Restart your terminal, then run the setup wizard:

```bash
notat setup
```

Follow the prompts to create your first environment (try "personal" to start).

## Your First 5 Minutes

### 1. Open Today's Daily Note
```bash
nd
```
This is your inbox. Write anything here.

### 2. Capture a Quick Thought
```bash
nt
```
A timestamped note appears. Jot down that fleeting idea.

### 3. Create a Task
In any note, start a line with `. ` (dot-space):
```
. Call dentist
. Review quarterly goals
```

### 4. Find Your Active Tasks
```bash
sa
```
See all your open tasks in one place, across all notes.

### 5. Search Your Thoughts
```bash
st docker
```
Search your thought notes for "docker".

## The 2-Letter Grammar

Commands follow `[VERB][SUBJECT]`:

**Verbs:**
- `n` = New
- `s` = Search (within a type)
- `p` = Pick (find file)
- `o` = Open
- `r` = Review (interactive)

**Subjects:**
- `d` = Daily
- `t` = Thought
- `a` = Action
- `r` = Resource

**Examples:**
- `nd` = New Daily
- `st` = Search Thoughts
- `pa` = Pick Action (find file)
- `oa` = Open Active task

## Task Markers

Start lines with these symbols:

- `. ` Open (to-do)
- `= ` Active (doing now)
- `x ` Done
- `, ` Parked (later)
- `? ` Question

Toggle states in your editor with `<leader>x`, `<leader>a`, `<leader>,`

## Next Steps

- **Full guide**: See [README.md](../README.md)
- **Design philosophy**: Read [docs/system-description.md](../docs/system-description.md)
- **Security**: Set up encryption with `notat secure init`
- **Customize**: Edit themes with `notat theme`

## Help

```bash
notat --help           # Show all commands
notat env --help       # Environment commands
notat secure --help    # Security commands
notat doctor           # Check your setup
```

## The Golden Rule

**Capture first, organize never.** Trust the search.
