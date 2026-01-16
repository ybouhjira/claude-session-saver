# Project-Specific Tasks

Custom tasks to run before closing or while away:

- Run all bats tests: bats tests/*.bats
- Check shellcheck: shellcheck save-session
- Update README if features changed
- Test on fresh directory: cd /tmp && save-session --quick
