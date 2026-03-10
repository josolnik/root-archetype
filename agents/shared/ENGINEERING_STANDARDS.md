# Engineering Standards

## Code Invariants

- Use typed boundaries for external data
- Use enums/constants, not ad hoc strings
- Feature-flag optional or expensive components
- Log exceptions with context (never silent `except: pass`)
- Thread-safe state updates for shared mutable state

## Numeric Parameter Policy

Every numeric value is classified as:
- **tunable**: runtime behavior control — typed config/dataclass + env override
- **invariant**: stable semantic limit — subsystem-local constant

Do NOT consolidate all numbers in one file; preserve subsystem ownership.

## Change Style

- One concern per change
- Reuse existing modules before adding helpers
- Follow existing project layout
- PRs adding numerics must include one-line classification

## Verification Minimum

1. Syntax check for modified Python files
2. Run targeted tests for touched behavior
3. Confirm feature-flag behavior
4. Update docs when behavior changes
