# Verification Loop

Use this workflow for every code-changing task.

## Step 1: Define success

Write observable acceptance criteria.

Each criterion must be verifiable by at least one of:

- Automated test
- Type or schema check
- Build
- Browser interaction
- API request
- Log or trace inspection
- Explicit manual inspection

## Step 2: Establish baseline

Before editing, run the narrowest relevant existing check when practical.

This distinguishes pre-existing failures from regressions introduced by the task.

Record:

- Command
- Result
- Existing failures
- Environment limitations

## Step 3: Implement minimally

Make the smallest coherent change that satisfies the acceptance criteria.

Avoid combining:

- Feature changes with broad formatting
- Bug fixes with unrelated refactors
- Dependency upgrades with product changes
- Architecture migrations with minor behavior changes

## Step 4: Run focused verification

Run checks closest to the modified behavior first.

Examples:

- Single test file
- Package-level type check
- Component test
- One API scenario
- One browser journey

Focused verification shortens the repair loop.

## Step 5: Run regression verification

After focused checks pass, run the relevant broader suite:

1. Format or format check
2. Lint
3. Type check
4. Unit or integration tests
5. Build
6. End-to-end tests when applicable

## Step 6: Verify user-visible behavior

For UI or interaction changes:

1. Start the application.
2. Open the affected page.
3. Execute the happy path.
4. Execute at least one relevant failure or boundary path.
5. Confirm the visible result.
6. Inspect console output.
7. Inspect failed network requests.
8. Record evidence.

Do not substitute reading JSX, HTML, CSS, or templates for browser verification.

## Step 7: Repair

For every failure:

1. Capture the exact message.
2. Locate the earliest meaningful cause.
3. Determine whether the failure is new or pre-existing.
4. Apply one targeted correction.
5. Re-run the failing check.
6. Re-run affected regression checks.

If five repair attempts fail, pause and reassess assumptions rather than continuing speculative edits.

## Step 8: Constraint opportunity

Ask whether the defect indicates a missing:

- Type
- Test
- Schema
- Lint rule
- Architecture boundary
- Script
- CI gate

Implement the constraint when proportionate to the risk.

## Step 9: Report

Report:

- What changed
- Why it changed
- Commands executed
- Results
- UI evidence, when relevant
- Constraints added
- Unverified areas
- Residual risks
- Recommended next action