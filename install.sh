#!/bin/bash
# Quick install for claude-session-saver

set -e

INSTALL_DIR="${HOME}/.local/bin"
REPO_URL="https://raw.githubusercontent.com/ybouhjira/claude-session-saver/main/save-session"

echo "Installing claude-session-saver..."

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download script
curl -fsSL "$REPO_URL" -o "$INSTALL_DIR/save-session"
chmod +x "$INSTALL_DIR/save-session"

# Check if in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "Add to your shell profile:"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo "✅ Installed! Run 'save-session' to save your work."
