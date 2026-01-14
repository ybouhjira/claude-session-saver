# Claude Session Saver

Save your Claude Code session work before closing. Ensures all projects are backed up to private GitHub repos.

## Features

- 🔍 **Auto-detects** projects with uncommitted changes
- 📦 **Creates GitHub repos** for projects without remotes
- 🌿 **Creates save branches** like `session-save/2024-01-14-1530`
- 📝 **Documents everything** in `~/.claude/session-saves/`
- ✅ **Confirms safe to close** when all work is saved

## Installation

```bash
# Clone
git clone https://github.com/ybouhjira/claude-session-saver.git ~/Projects/claude-session-saver

# Add to PATH (add to ~/.zshrc)
export PATH="$HOME/Projects/claude-session-saver:$PATH"

# Or create symlink
ln -sf ~/Projects/claude-session-saver/save-session ~/.local/bin/save-session
```

## Usage

```bash
# Basic - save all work
save-session

# Quick mode - skip repo creation prompts
save-session --quick

# Full mode - also setup CI/CD and create issues
save-session --full
```

## What It Does

1. **Scans** current directory and `~/Projects/*` for git repos
2. **Checks** for uncommitted changes
3. **Creates** private GitHub repos for projects without remotes
4. **Commits** changes to a timestamped save branch
5. **Pushes** to GitHub
6. **Logs** everything to `~/.claude/session-saves/YYYY-MM-DD_HH-MM-SS.md`

## Session Log Format

```markdown
# Session Save - 2024-01-14 15:30:00

## Projects Checked
- **my-project**: ✅ Saved to branch `session-save/2024-01-14-1530`
- **another-project**: ✅ All saved (branch: main)

## Summary
- Repos created: 1
- Commits made: 2
- All saved: true
```

## Resume Later

```bash
# View last session
cat ~/.claude/session-saves/$(ls -t ~/.claude/session-saves | head -1)

# List all sessions
ls -la ~/.claude/session-saves/
```
