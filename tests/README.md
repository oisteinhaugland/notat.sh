# Test Suite Organization

This directory contains all test and debugging scripts for notat.sh, organized by purpose.

## Directory Structure

### `unit/`
Tests for individual features and functions in isolation.

- **`test_toggle_task.sh`** - Tests task state toggling functionality
- **`test_preview.sh`** - Tests FZF preview rendering
- **`test_env_switch.sh`** - Tests environment switching logic

### `integration/`
Tests that verify complete workflows and system integration.

- **`test_final_implementation.sh`** - End-to-end system validation
- **`test_notes.sh`** - Full note management workflow tests

### `debug/`
Debugging and diagnostic scripts (primarily for development).

- **`debug_nvim.sh`** - Neovim integration debugging
- **`check_nvim_config.sh`** - Validates Neovim configuration
- **`reproduce_action_bug.zsh`** - Reproduces specific action-related bugs
- **`verify_fix.zsh`** - Verifies bug fixes

### `fixtures/`
Test data and sample files used by tests.

- **`test_notes/`** - Sample note files for testing

## Running Tests

### Run all unit tests
```bash
for test in tests/unit/*.sh; do
    echo "Running $test..."
    bash "$test"
done
```

### Run integration tests
```bash
for test in tests/integration/*.sh; do
    echo "Running $test..."
    bash "$test"
done
```

### Run a specific test
```bash
bash tests/unit/test_toggle_task.sh
```

## Adding New Tests

1. **Unit tests**: Place in `unit/` if testing a single function or feature
2. **Integration tests**: Place in `integration/` if testing workflows
3. **Debug scripts**: Place in `debug/` if for troubleshooting
4. **Test data**: Place in `fixtures/` if providing sample data

## Notes

- Tests should be idempotent and not affect production data
- Use the `fixtures/` directory for any test data
- Debug scripts may be removed once issues are resolved
