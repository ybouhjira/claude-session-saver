# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Session Saver is a **disaster recovery tool** for Claude Code sessions. Run it before closing Claude Code to ensure all work is backed up to GitHub. If your laptop is lost or destroyed, you can recover everything from the remote repos.

## Architecture

Single bash script (`save-session`) that:
1. Saves uncommitted changes from the current Claude Code session
2. Creates private GitHub repos for projects without remotes (via `gh` CLI)
3. Commits changes to timestamped branches (`session-save/YYYY-MM-DD-HHMM`)
4. Pushes to GitHub and logs results to `~/.claude/session-saves/`

## Commands

```bash
# Run the tool
./save-session

# Quick mode - skip prompts
./save-session --quick

# Run tests
bats tests/save-session.bats

# Install globally
./install.sh
```

## Dependencies

- `git` - For version control operations
- `gh` - GitHub CLI (must be authenticated) for creating repos and pushing
- `bats-core` - For running tests (install with `brew install bats-core`)

## Key Files

- `save-session` - Main executable bash script
- `install.sh` - Downloads script to `~/.local/bin/`
- `tests/save-session.bats` - Test suite
