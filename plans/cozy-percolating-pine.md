# Plan: Consolidate Playwright E2E Tests into Single Python File

## Context

The `/Volumes/data/working/ai/matrix/cdp/e2e-test-case/playwright/` directory contains 31 shell scripts for E2E testing:
- 10 login tests (cdp-log-001 to cdp-log-010)
- 8 registration tests (cdp-reg-001 to cdp-reg-008)
- 4 home page tests (cdp-home-001 to cdp-home-004)
- 3 customer tests (cdp-customer-001 to cdp-customer-003)
- 6 edge case tests (cdp-edge-001 to cdp-edge-006)

Two tests have been converted to Python: `cdp-log-001.py` and `cdp-log-002.py`.

Goal: Consolidate ALL tests into a single `cdp-e2e.py` file that can run any test case.

## Design

### Structure

```
cdp-e2e.py
├── Config (PROJECT_DIR, CONFIG_PATH)
├── run_playwright(session, args) - Execute playwright-cli with session
├── TestCase class
│   ├── name, description
│   ├── steps: list of (action, args)
│   └── run() - Execute all steps
└── Test definitions
    ├── LOGIN_TESTS = {001: TestCase(...), 002: TestCase(...), ...}
    ├── REG_TESTS = {001: TestCase(...), ...}
    ├── HOME_TESTS = {...}
    ├── CUSTOMER_TESTS = {...}
    ├── EDGE_TESTS = {...}
```

### TestCase Definition Pattern

```python
class TestCase:
    def __init__(self, name: str, description: str, steps: list):
        self.name = name
        self.description = description
        self.steps = steps  # e.g., [("open", url), ("fill", ref, value), ("click", ref)]

    def run(self, session_name: str):
        try:
            for step in self.steps:
                action = step[0]
                args = step[1:]
                run_playwright(session_name, [action] + list(args))
        finally:
            run_playwright(session_name, ["close"])
```

### Running Tests

```bash
# Run all tests
python3 cdp-e2e.py

# Run specific test
python3 cdp-e2e.py --test cdp-log-001

# Run by category
python3 cdp-e2e.py --category login
```

## Files

- **Input**: 31 `.sh` files in `playwright/`
- **Output**: `playwright/cdp-e2e.py` (single consolidated file)
- **Keep unchanged**: Original `.sh` files

## Test Cases to Implement

### Login Tests (10)
| ID | Description |
|----|-------------|
| cdp-log-001 | Successful login with valid credentials |
| cdp-log-002 | Failed login with wrong password |
| cdp-log-003 | Login page UI element verification |
| cdp-log-004 | Navigate to register page |
| cdp-log-005 | Empty username validation |
| cdp-log-006 | Empty password validation |
| cdp-log-007 | Invalid phone format |
| cdp-log-008 | Navigate to forgot password |
| cdp-log-009 | Remember me checkbox |
| cdp-log-010 | Logout after login |

### Registration Tests (8)
| ID | Description |
|----|-------------|
| cdp-reg-001 | Successful registration |
| cdp-reg-002 | Form validation (empty fields) |
| cdp-reg-003 | Registration page UI verification |
| cdp-reg-004 | Navigate to login from register |
| cdp-reg-005 | Username already exists |
| cdp-reg-006 | Invalid email format |
| cdp-reg-007 | Password too short |
| cdp-reg-008 | Password confirmation mismatch |

### Home Tests (4)
### Customer Tests (3)
### Edge Tests (6)

## Verification

1. Run `python3 cdp-e2e.py` to see help/available tests
2. Run individual tests to verify they work
3. Run `python3 cdp-e2e.py --test cdp-log-001` to verify single test
