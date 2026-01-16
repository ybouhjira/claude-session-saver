# Claude Session Saver 🔄

[![CI](https://github.com/ybouhjira/claude-session-saver/actions/workflows/ci.yml/badge.svg)](https://github.com/ybouhjira/claude-session-saver/actions/workflows/ci.yml)

**Never lose your Claude Code work again.** Save all session work to GitHub before closing your laptop.

![Demo](demo.gif)

> 💡 Built for Claude Code users who want peace of mind knowing their work is safely backed up.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/ybouhjira/claude-session-saver/main/install.sh | bash
```

## Why?

You're deep in a coding session with Claude Code. Laptop dies. Power outage. You close the terminal by accident. **Your work is gone.**

This tool ensures everything gets pushed to GitHub before you close.

## Features

| Feature | Description |
|---------|-------------|
| 🔍 **Smart Detection** | Finds uncommitted changes, unpushed commits, stashes |
| 📦 **Auto-Create Repos** | Creates private GitHub repos for projects without remotes |
| 🌿 **Save Branches** | Creates timestamped branches like `session-save/2024-01-14-1530` |
| 💡 **Close Suggestions** | Reminds you about open PRs, TODO comments, local branches |
| ☕ **Away Mode** | Suggests background tasks (tests, lints) based on project type |
| 📋 **Custom Tasks** | Add project-specific tasks via `claude-session-save-logic.md` |
| 📝 **Session Logs** | Documents everything in `~/.claude/session-saves/` |

## Usage

```bash
# Full save with suggestions (default)
save-session

# Quick save only (no suggestions)
save-session --quick
```

## Example Output

```
╔══════════════════════════════════════════════════════╗
║      🔄 Claude Session Saver                         ║
╚══════════════════════════════════════════════════════╝

Checking current directory...
📁 my-project
   3 uncommitted changes
   ✓ Committed to session-save/2024-01-14-1530
   ✓ Pushed to GitHub

══════════════════════════════════════════════════════
✅ All work saved! You can close Claude Code.

💡 Before you close:
   📦 You have 2 stash(es) - run 'git stash list' to review
   🔄 You have 1 open PR(s) - run 'gh pr list' to review

══════════════════════════════════════════════════════
☕ Away Mode - Tasks that can run while you're gone:

Suggested tasks for this project:
   1. 🧪 Run tests: npm test
   2. ✨ Run linter: npm run lint
   3. 🚀 Create PR: gh pr create --fill

👋 Safe to close!
```

## Custom Project Tasks

Add a `claude-session-save-logic.md` file to any project:

```markdown
# My Project Tasks

- Run database migrations: npm run migrate
- Deploy to staging: ./deploy.sh staging
- Check error logs: tail -f logs/error.log
```

These will appear in the Away Mode output.

## Requirements

- `git` - Version control
- `gh` - [GitHub CLI](https://cli.github.com/) (authenticated)
- macOS or Linux

## How It Works

1. **Checks** current directory for uncommitted changes
2. **Creates** private GitHub repo if no remote exists
3. **Commits** changes to a timestamped save branch
4. **Pushes** to GitHub
5. **Shows** suggestions and background tasks
6. **Logs** everything to `~/.claude/session-saves/`

## Resume Later

```bash
# View last session log
cat ~/.claude/session-saves/$(ls -t ~/.claude/session-saves | head -1)

# List all session saves
ls -la ~/.claude/session-saves/
```

## Contributing

PRs welcome! Run tests with:

```bash
bats tests/*.bats
```

## License

MIT
