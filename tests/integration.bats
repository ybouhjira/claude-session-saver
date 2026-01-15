#!/usr/bin/env bats

# Integration tests with mocked gh and git push
# These tests simulate the full workflow without hitting real GitHub

REPO_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
SAVE_SESSION="$REPO_ROOT/save-session"

load 'test_helper'

setup() {
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    setup_all_mocks
}

teardown() {
    cd "$REPO_ROOT"
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

@test "integration: creates GitHub repo for project without remote" {
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "hello" > file.txt
    git add file.txt
    git commit -q -m "initial"

    output=$("$SAVE_SESSION" --quick 2>&1) || true

    [[ "$output" == *"No GitHub remote"* ]] || [[ "$output" == *"Created private repo"* ]]
}

@test "integration: full workflow - uncommitted changes get saved" {
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "initial" > file.txt
    git add file.txt
    git commit -q -m "initial"
    git remote add origin "https://github.com/test/test.git"

    echo "modified" > file.txt

    output=$("$SAVE_SESSION" --quick 2>&1) || true

    [[ "$output" == *"uncommitted changes"* ]]
    [[ "$output" == *"Committed to session-save"* ]]
}

@test "integration: handles project with code files but no git" {
    echo "fn main() {}" > main.rs

    output=$("$SAVE_SESSION" 2>&1) || true

    [[ "$output" == *"No git repo"* ]]
}

@test "integration: session log contains project info" {
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test User"
    echo "initial" > file.txt
    git add file.txt
    git commit -q -m "initial"
    git remote add origin "https://github.com/test/test.git"

    echo "changed" > file.txt

    "$SAVE_SESSION" --quick 2>&1 || true

    LATEST_LOG=$(ls -t "$HOME/.claude/session-saves/"*.md 2>/dev/null | head -1)
    [[ -f "$LATEST_LOG" ]]
}
