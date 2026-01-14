# Claude Session Saver

Save your Claude Code session work before closing. Ensures all projects are backed up to private GitHub repos.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/ybouhjira/claude-session-saver/main/install.sh | bash
```

## Requirements

- `git` - Version control
- `gh` - [GitHub CLI](https://cli.github.com/) (authenticated)
- macOS/Linux

## Features

- 🔍 **Auto-detects** projects with uncommitted changes
- 📦 **Creates GitHub repos** for projects without remotes
- 🌿 **Creates save branches** like `session-save/2024-01-14-1530`
- 📝 **Documents everything** in `~/.claude/session-saves/`
- ✅ **Confirms safe to close** when all work is saved

## Usage

```bash
# Save all work
save-session

# Quick mode - skip prompts
save-session --quick
```

## What It Does

1. **Scans** current directory and `~/Projects/*` for git repos
2. **Checks** for uncommitted changes
3. **Creates** private GitHub repos for projects without remotes
4. **Commits** changes to a timestamped save branch
5. **Pushes** to GitHub
6. **Logs** everything to `~/.claude/session-saves/`

## Example Output

```
╔══════════════════════════════════════════════════════╗
║      🔄 Claude Session Saver                         ║
╚══════════════════════════════════════════════════════╝

✓ my-app - All saved
📁 another-project
   5 uncommitted changes
   ✓ Committed to session-save/2024-01-14-1530
   ✓ Pushed to GitHub

══════════════════════════════════════════════════════
✅ All work saved! You can close Claude Code.
```

## Resume Later

```bash
# View last session
cat ~/.claude/session-saves/$(ls -t ~/.claude/session-saves | head -1)
```

## License

MIT
