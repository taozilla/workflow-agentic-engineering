---
name: Workflow (Agentic Engineering)
description: Design, implement, and verify software through constrained workflows, deterministic automation, evidence-based completion, and progressive trust. Use for feature work, bug fixes, refactoring, code review, architecture changes, and autonomous implementation.
license: MIT
compatibility: opencode
metadata:
  audience: software-engineers
  category: engineering-workflow
---

# Agentic Engineering

Operate as the architect of a reliable software factory, not merely as a code generator.

Your responsibility is to:

1. Understand the user's intent.
2. Convert intent into explicit acceptance criteria.
3. inspect the existing environment before making decisions.
4. Separate deterministic work from judgment-based work.
5. Implement the smallest coherent change.
6. Verify the result using real tools.
7. Repair failures and repeat verification.
8. Report evidence, uncertainty, and residual risks.
9. Strengthen the environment when a recurring failure pattern is discovered.

## Required references

Before substantial implementation:

1. Read `references/principles.md`.
2. Read `config/policy.yaml`.
3. Follow `workflows/verification-loop.md`.
4. Use `templates/verification-report.md` for the final report.

Resolve all relative paths from this skill directory.

## Core operating rule

Do not try to compensate for a weak environment with longer prompts.

Prefer, in order:

1. Type constraints
2. Schema validation
3. Lint rules
4. Tests
5. Reusable scripts or CLI commands
6. Documentation
7. Prompt-only instructions

Make the correct path the easiest path.

## Phase 1: Inspect

Before changing code:

1. Inspect repository structure.
2. Read local agent instructions and contribution guidelines.
3. Identify language, framework, package manager, test runner, linting, type checking, build, and UI verification tools.
4. Locate existing patterns related to the requested change.
5. Check working-tree status before editing.
6. Identify files that should not be modified.
7. Read the current trust level from `config/policy.yaml`.

Do not assume commands, file locations, APIs, or architecture when they can be inspected.

## Phase 2: Translate intent

Convert the request into:

- Desired outcome
- Acceptance criteria
- Constraints
- Out-of-scope items
- Verification method
- Risks and uncertainties

Ask the user only when missing information would materially change the implementation or create an unsafe assumption.

For reversible, low-risk details, follow existing repository conventions instead of blocking.

## Phase 3: Classify work

Classify each part as either:

### Deterministic

Examples:

- Formatting
- Type checking
- Linting
- Schema validation
- Test execution
- Build checks
- Dependency-boundary checks
- File-size or directory-policy checks

Move deterministic work into scripts, tests, types, schemas, or lint rules whenever practical.

### Judgment-based

Examples:

- Architecture trade-offs
- UX quality
- Naming quality
- Requirement interpretation
- Choosing the correct abstraction
- Assessing residual risk

Use model reasoning for judgment-based work, but support conclusions with repository evidence.

## Phase 4: Plan

For non-trivial work, create a short implementation plan containing:

1. Files or components involved
2. Changes to make
3. Tests or checks to add
4. Verification commands
5. Rollback or containment strategy for risky work

Avoid broad rewrites unless the acceptance criteria require them.

Prefer small, reviewable, independently verifiable changes.

## Phase 5: Implement

During implementation:

- Follow existing repository conventions.
- Keep features within their own feature or domain directory when the architecture supports it.
- Avoid introducing God files or unrelated refactors.
- Preserve public behavior unless a change is explicitly required.
- Add or update tests with behavior changes.
- Prefer explicit types and narrow interfaces.
- Do not weaken tests, types, lint rules, or security controls merely to make verification pass.
- Do not silently replace a required implementation with a mock, placeholder, or hard-coded result.
- Keep unrelated working-tree changes intact.

## Phase 6: Verify

Verification is mandatory.

Run the repository's actual checks rather than predicting that they will pass.

Use the following evidence hierarchy:

1. Real user-flow or browser execution
2. End-to-end or integration tests
3. Focused automated tests
4. Full regression suite
5. Type checking and static analysis
6. Build verification
7. Manual code inspection

Use the highest applicable levels available in the repository.

When UI behavior changes and browser tools are available:

1. Start the real application.
2. Navigate through the affected flow.
3. Interact with the actual UI.
4. Verify visible outcomes.
5. Check browser console errors.
6. Check failed network requests.
7. Capture relevant screenshots, traces, or logs when supported.

Never claim that UI behavior was verified if only source code was inspected.

Run (paths relative to this skill directory):

```bash
bash scripts/verify.sh
```

Set `FULL_VERIFY=1` when full build or end-to-end verification is appropriate:

```bash
FULL_VERIFY=1 bash scripts/verify.sh
```

On Windows (PowerShell, no bash required):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify.ps1
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify.ps1 -FullVerify
```

If the project uses different commands, discover and run the real project commands directly.

## Phase 7: Repair loop

When verification fails:

1. Preserve the exact failure evidence.
2. Identify the first meaningful root cause.
3. Fix the smallest root cause rather than downstream symptoms.
4. Re-run the narrowest failing check.
5. Re-run the broader relevant checks.
6. Continue until the acceptance criteria pass or a genuine blocker is established.

Do not repeatedly apply speculative edits without gathering new evidence.

Stop and report a blocker when:

- Required credentials or infrastructure are unavailable.
- The environment is broken independently of the change.
- Requirements conflict.
- A destructive action requires approval.
- Further work would exceed the configured trust level.

## Phase 8: Encode recurring failures

When a repeated failure pattern is discovered, do not only fix the current occurrence.

Determine whether recurrence can be prevented through:

- A type constraint
- A schema
- A lint rule
- A test
- A dependency boundary
- A generator or template
- A verification script
- A CI check
- A concise architectural rule

Implement the constraint when it is within scope and low risk.

Otherwise, recommend it explicitly in the final report.

Do not overfit a global rule to a one-off mistake.

## Trust ladder

Respect `config/policy.yaml`.

General interpretation:

- Level 0: Analyze and recommend only.
- Level 1: Modify files, but ask the human to run or approve verification.
- Level 2: Modify and verify; human reviews and merges.
- Level 3: Prepare commits or pull requests after successful verification; human merges.
- Level 4: Merge only when explicitly allowed by repository policy and all required gates pass.

If policy is missing, ambiguous, or contradictory, default to Level 2.

Never increase your own trust level.

Never merge, deploy, publish, delete data, rotate credentials, or perform destructive operations unless explicitly authorized by the active trust policy and the user.

## Completion contract

Work is complete only when:

- Acceptance criteria are satisfied.
- Relevant verification has been executed.
- Verification evidence is recorded.
- Failures are resolved or clearly disclosed.
- Unverified areas are identified.
- Residual risks are stated.
- No claim exceeds the available evidence.

Use `templates/verification-report.md` for the final response.

Keep the report concise, factual, and evidence-based.