#!/bin/bash
# Test helper functions for mocking external commands

# Store real paths before any mocking
REAL_GIT=$(which git)
REAL_GH=$(which gh 2>/dev/null || echo "/usr/local/bin/gh")

# Create a mock gh command that simulates success
setup_gh_mock() {
    local mock_dir="$TEST_DIR/.mocks"
    mkdir -p "$mock_dir"

    # Create mock gh script
    cat > "$mock_dir/gh" << 'MOCK'
#!/bin/bash
# Mock gh CLI for testing

case "$1" in
    repo)
        case "$2" in
            create)
                # Simulate successful repo creation by adding remote
                if [[ -d .git ]]; then
                    # Only add remote if it doesn't exist
                    git remote get-url origin &>/dev/null || \
                        git remote add origin "https://github.com/test-user/test-repo.git"
                fi
                echo "https://github.com/test-user/test-repo"
                exit 0
                ;;
            *)
                exit 0
                ;;
        esac
        ;;
    *)
        exit 0
        ;;
esac
MOCK
    chmod +x "$mock_dir/gh"

    # Prepend mock dir to PATH
    export PATH="$mock_dir:$PATH"
    export GH_MOCKED=1
}

# Create a mock that intercepts git push only
setup_git_push_mock() {
    local mock_dir="$TEST_DIR/.mocks"
    mkdir -p "$mock_dir"

    # Create wrapper script that intercepts push only
    cat > "$mock_dir/git" << MOCK
#!/bin/bash
# Mock git wrapper - intercepts push, passes through everything else

if [[ "\$1" == "push" ]]; then
    # Simulate successful push
    exit 0
else
    # Pass through to real git
    $REAL_GIT "\$@"
fi
MOCK
    chmod +x "$mock_dir/git"

    export PATH="$mock_dir:$PATH"
    export GIT_PUSH_MOCKED=1
}

# Setup both mocks
setup_all_mocks() {
    setup_gh_mock
    setup_git_push_mock
}
