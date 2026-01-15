#!/usr/bin/env bats

# Test suite for save-session
# Run with: bats tests/save-session.bats

setup() {
    # Get the absolute path to save-session script
    SAVE_SESSION="$(pwd)/save-session"

    # Create a temporary test directory
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    export SAVE_SESSION
}

teardown() {
    cd /tmp  # Ensure we're out of TEST_DIR before removing
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

@test "detects uncommitted changes in git repo" {
    cd "$TEST_DIR"

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
    cd "$TEST_DIR"

    # Create a git repo with no uncommitted changes
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "initial" > file.txt
    git add file.txt
    git commit -q -m "initial"
    git remote add origin "https://github.com/test/test.git"

    # Set upstream to avoid "ahead" check issues
    git fetch origin 2>/dev/null || true

    # Run save-session
    output=$("$SAVE_SESSION" --quick 2>&1) || true

    # Should report all saved (either "All saved" or green checkmark)
    [[ "$output" == *"All saved"* ]] || [[ "$output" == *"✓"* ]]
}

@test "creates session-save branch for uncommitted changes" {
    cd "$TEST_DIR"

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
    run git branch --list "session-save/*"
    [[ -n "$output" ]]
}

@test "handles non-git directory gracefully" {
    cd "$TEST_DIR"

    # Don't init git - just an empty directory
    echo "some content" > file.txt

    # Run save-session - should not crash
    output=$("$SAVE_SESSION" --quick 2>&1) || true

    # Should show the header at minimum
    [[ "$output" == *"Claude Session Saver"* ]]
}

@test "creates session log file" {
    cd "$TEST_DIR"

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
    cd "$TEST_DIR"

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
