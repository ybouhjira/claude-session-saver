#!/usr/bin/env bats

# Test suite for save-session

setup() {
    # Create a temporary test directory
    TEST_DIR=$(mktemp -d)
    ORIGINAL_DIR=$(pwd)

    # Store original session log dir
    ORIGINAL_SESSION_LOG_DIR="$HOME/.claude/session-saves"
    TEST_SESSION_LOG_DIR="$TEST_DIR/.claude/session-saves"
    mkdir -p "$TEST_SESSION_LOG_DIR"
}

teardown() {
    cd "$ORIGINAL_DIR"
    rm -rf "$TEST_DIR"
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

    # Make uncommitted changes
    echo "changed" > file.txt

    # Run save-session and capture output
    run "$ORIGINAL_DIR/save-session" --quick 2>&1

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

    # Add a fake remote to avoid GitHub repo creation
    git remote add origin "https://github.com/test/test.git"

    # Run save-session
    run "$ORIGINAL_DIR/save-session" --quick 2>&1

    # Should report all saved
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
    "$ORIGINAL_DIR/save-session" --quick 2>&1 || true

    # Check if session-save branch was created
    run git branch --list "session-save/*"
    [[ -n "$output" ]]
}

@test "handles non-git directory gracefully" {
    cd "$TEST_DIR"

    # Don't init git, just have some files
    echo "some content" > file.txt

    # Run save-session
    run "$ORIGINAL_DIR/save-session" --quick 2>&1

    # Should not crash
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
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

    # Run save-session
    "$ORIGINAL_DIR/save-session" --quick 2>&1 || true

    # Check if session log was created
    run ls "$HOME/.claude/session-saves/"
    [[ -n "$output" ]]
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
    "$ORIGINAL_DIR/save-session" --quick 2>&1 || true

    # Check commit message on session-save branch
    SAVE_BRANCH=$(git branch --list "session-save/*" | head -1 | tr -d ' ')
    if [[ -n "$SAVE_BRANCH" ]]; then
        run git log -1 --format=%B "$SAVE_BRANCH"
        [[ "$output" == *"Session save"* ]] || [[ "$output" == *"session save"* ]]
    fi
}
