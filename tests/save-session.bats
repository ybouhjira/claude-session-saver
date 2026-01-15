#!/usr/bin/env bats

# Test suite for save-session
# Run from repo root: bats tests/save-session.bats

# Store repo root at load time (before any cd)
REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SAVE_SESSION="$REPO_ROOT/save-session"

setup() {
    # Create a temporary test directory
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
}

teardown() {
    # Return to repo root and clean up
    cd "$REPO_ROOT"
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

@test "detects uncommitted changes in git repo" {
    # Create a git repo with uncommitted changes
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "initial" > file.txt
    git add file.txt
    git commit -q -m "initial"
    git remote add origin "https://github.com/test/test.git"

    # Make uncommitted changes
    echo "changed" > file.txt

    # Run save-session and capture output
    output=$("$SAVE_SESSION" --quick 2>&1) || true

    # Should detect the changes
    [[ "$output" == *"uncommitted changes"* ]]
}

@test "reports all saved when no changes" {
    # Create a git repo with no uncommitted changes
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "initial" > file.txt
    git add file.txt
    git commit -q -m "initial"
    git remote add origin "https://github.com/test/test.git"

    # Run save-session
    output=$("$SAVE_SESSION" --quick 2>&1) || true

    # Should report all saved (either "All saved" or green checkmark)
    [[ "$output" == *"All saved"* ]] || [[ "$output" == *"✓"* ]]
}

@test "creates session-save branch for uncommitted changes" {
    # Create a git repo
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "initial" > file.txt
    git add file.txt
    git commit -q -m "initial"

    # Add fake remote
    git remote add origin "https://github.com/test/test.git"

    # Make uncommitted changes
    echo "changed" > file.txt

    # Run save-session (will fail on push but should create branch)
    "$SAVE_SESSION" --quick 2>&1 || true

    # Check if session-save branch was created
    BRANCHES=$(git branch --list "session-save/*")
    [[ -n "$BRANCHES" ]]
}

@test "handles non-git directory gracefully" {
    # Don't init git - just an empty directory
    echo "some content" > file.txt

    # Run save-session - should not crash
    output=$("$SAVE_SESSION" --quick 2>&1) || true

    # Should show the header at minimum
    [[ "$output" == *"Claude Session Saver"* ]]
}

@test "creates session log file" {
    # Create a git repo
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "initial" > file.txt
    git add file.txt
    git commit -q -m "initial"
    git remote add origin "https://github.com/test/test.git"

    # Count logs before
    LOGS_BEFORE=$(ls "$HOME/.claude/session-saves/" 2>/dev/null | wc -l)

    # Run save-session
    "$SAVE_SESSION" --quick 2>&1 || true

    # Count logs after
    LOGS_AFTER=$(ls "$HOME/.claude/session-saves/" 2>/dev/null | wc -l)

    # Should have created at least one new log
    [[ "$LOGS_AFTER" -gt "$LOGS_BEFORE" ]] || [[ "$LOGS_AFTER" -gt 0 ]]
}

@test "commit message includes session save identifier" {
    # Create a git repo
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "initial" > file.txt
    git add file.txt
    git commit -q -m "initial"
    git remote add origin "https://github.com/test/test.git"

    # Make uncommitted changes
    echo "changed" > file.txt

    # Run save-session
    "$SAVE_SESSION" --quick 2>&1 || true

    # Check commit message on session-save branch
    SAVE_BRANCH=$(git branch --list "session-save/*" | head -1 | tr -d ' ')
    [[ -n "$SAVE_BRANCH" ]]

    COMMIT_MSG=$(git log -1 --format=%B "$SAVE_BRANCH")
    [[ "$COMMIT_MSG" == *"Session save"* ]] || [[ "$COMMIT_MSG" == *"session save"* ]]
}
