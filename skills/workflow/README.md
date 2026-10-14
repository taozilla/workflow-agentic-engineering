# Workflow (Agentic Engineering)

An OpenCode skill that makes software work verifiable instead of merely plausible.

It gives an agent a constrained workflow — inspect, translate intent, classify work, plan, implement, verify, repair, encode — plus a configurable trust policy, a verification loop, and a report template so that every finished task carries evidence.

- **Skill name:** `Workflow (Agentic Engineering)`
- **Category:** `engineering-workflow`
- **Audience:** software engineers
- **Compatibility:** opencode
- **License:** MIT

## Contents

```
skills/workflow/
├── SKILL.md                          # Entry point the agent loads
├── config/
│   ├── policy.yaml                   # Trust level, permissions, limits
│   └── Completion_contract.yaml      # Stricter contract for a higher trust level
├── references/
│   └── principles.md                 # Eight operating principles
├── workflows/
│   └── verification-loop.md          # Nine-step verification loop
├── scripts/
│   ├── verify.sh                     # POSIX / macOS / Linux verification runner
│   └── verify.ps1                    # Windows PowerShell verification runner
└── templates/
    └── verification-report.md        # Final report template
```

## How it works

The agent loads `SKILL.md` and is expected to follow it. Before substantial implementation it reads:

1. `references/principles.md`
2. `config/policy.yaml`
3. `workflows/verification-loop.md`

and uses `templates/verification-report.md` for the final response. All relative paths resolve from this skill directory.

### The eight phases

| Phase | Purpose |
|---|---|
| 1. Inspect | Read the repo, its conventions, its toolchain, and the current trust level before changing anything. |
| 2. Translate intent | Turn the request into outcome, acceptance criteria, constraints, out-of-scope, verification method, and risks. |
| 3. Classify work | Split the work into deterministic work (move to scripts, types, schemas, lint) and judgment-based work (use reasoning plus repo evidence). |
| 4. Plan | For non-trivial work, list files, changes, checks, verification commands, and rollback strategy. |
| 5. Implement | Smallest coherent change; follow existing conventions; never weaken tests, types, or lint to go green. |
| 6. Verify | Run the repository's real checks, highest applicable level first. |
| 7. Repair | Fix the first real root cause, re-run narrow then broad checks; report blockers instead of guessing. |
| 8. Encode | Turn recurring failures into types, schemas, lint rules, tests, boundaries, or CI gates. |

### Core rule

Do not compensate for a weak environment with longer prompts. Prefer, in order:

1. Type constraints
2. Schema validation
3. Lint rules
4. Tests
5. Reusable scripts or CLI commands
6. Documentation
7. Prompt-only instructions

Make the correct path the easiest path.

## Trust ladder

Autonomy is configured in `config/policy.yaml`, not assumed.

| Level | Behaviour |
|---|---|
| 0 | Analyze and recommend only. |
| 1 | Modify files; human runs or approves verification. |
| 2 | Modify and verify; human reviews and merges. |
| 3 | Prepare commits or pull requests; human merges. |
| 4 | Merge autonomously, only when policy explicitly allows it and every gate passes. |

The agent never raises its own trust level. If the policy is missing, ambiguous, or contradictory, it defaults to level 2.

Merging, deploying, publishing, deleting data, rotating credentials, and other destructive operations stay unauthorized unless the active policy and the user both allow them.

## Configuration

### `config/policy.yaml`

Default active policy.

```yaml
trust_level: 2
```

Key sections:

| Key | Meaning |
|---|---|
| `trust_level` | Current rung of the ladder above. |
| `permissions` | What the agent may do: `edit_files`, `install_dependencies` (`ask`), `run_local_commands`, `run_browser_verification`, `create_commit`, `create_pull_request`, `merge`, `deploy`, `destructive_operations`. |
| `verification` | Required gates, e.g. `require_ui_flow_for_ui_changes`, `require_console_check_for_ui_changes`, `require_network_check_for_ui_changes`. |
| `review` | `human_review` or `human_sampling`, verifier count. |
| `limits` | `max_repair_iterations: 5`, `max_files_changed_without_replanning: 12`, `max_new_dependency_count: 0`. |
| `fallback` | Defaults when policy is silent: `ambiguous_action: ask`, `failed_verification: do_not_merge`. |

### `config/Completion_contract.yaml`

The stricter profile, meant to be layered onto `policy.yaml` when the repository's verification is proven to catch real defects.

```yaml
trust_level: 3
permissions:
  create_commit: true
  create_pull_request: true
  merge: false
review:
  strategy: human_sampling
  verifier_count: 2
```

It is a contract, not a standalone policy: keep `merge: false` and rely on `policy.yaml` for everything else.

## Verification scripts

Both runners detect the repository root (`git rev-parse --show-toplevel`), detect the package manager from the lockfile, and run the first available script from each group. Missing groups are skipped, not failed.

| Group | Candidate npm scripts |
|---|---|
| format check | `format:check`, `check:format`, `prettier:check` |
| lint | `lint`, `check:lint` |
| type check | `typecheck`, `type-check`, `check:types`, `types` |
| tests | `test:ci`, `test`, `check:test` |
| build *(full only)* | `build`, `check:build` |
| end-to-end *(full only)* | `test:e2e`, `e2e`, `playwright:test` |

Package manager detection order: `pnpm-lock.yaml` → pnpm, `yarn.lock` → yarn, `bun.lock`/`bun.lockb` → bun, otherwise npm.

### macOS / Linux / WSL

```bash
bash scripts/verify.sh
FULL_VERIFY=1 bash scripts/verify.sh
```

### Windows (PowerShell, no bash needed)

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify.ps1 -FullVerify
```

### Exit codes

| Code | Meaning |
|---|---|
| `0` | All discovered checks passed (skipped groups do not count as failures). |
| `1` | One or more check groups failed. |
| `2` | Environment unusable: no `package.json`, or Node / package manager missing from PATH. |

If the target project is not a Node project, or uses different commands, run the project's native verification directly — the scripts are a convenience layer, not the source of truth.

## Verification loop

`workflows/verification-loop.md` defines the nine steps to run for every code-changing task:

1. Define success in observable acceptance criteria.
2. Establish a baseline so pre-existing failures are not blamed on the change.
3. Implement minimally.
4. Run focused verification closest to the change.
5. Run the broader regression suite: format → lint → types → tests → build → e2e.
6. Verify user-visible behavior in a real browser for UI changes, including console and failed network requests.
7. Repair: capture the exact message, find the earliest cause, one targeted fix, re-run.
8. Look for a missing constraint that would have prevented the defect.
9. Report.

The evidence hierarchy, strongest first: real user-flow execution → e2e/integration tests → focused tests → full regression suite → types and static analysis → build → manual inspection. Never claim UI behavior was verified when only source was read.

## Completion contract

Work counts as complete only when acceptance criteria are satisfied, verification actually ran, evidence is recorded, failures are resolved or disclosed, unverified areas are named, residual risks are stated, and no claim exceeds the evidence.

The final report uses `templates/verification-report.md`:

- **Outcome** — status: Verified / Partially verified / Unverified / Blocked
- **Changes** — behavior changed, files involved, tests or constraints added
- **Acceptance criteria** — criterion, status, evidence
- **Verification** — focused tests, lint, type check, build, UI flow
- **Environment improvements** — constraints added, or an explicit statement that none were appropriate
- **Remaining risks** — unverified behavior, pre-existing failures, assumptions
- **Next action** — ready for review, needs clarification, or blocked

Use "Verified", "Partially verified", "Unverified", or "Blocked". Phrases such as "should work" or "looks correct" are not acceptable substitutes for execution.

## Installation

Copy the `workflow/` directory into your OpenCode skills directory, for example:

```text
~/.config/opencode/skills/workflow/          # Linux / macOS
%USERPROFILE%\.config\opencode\skills\workflow\   # Windows
```

No dependencies to install. The scripts require Node.js plus the target project's package manager.

## License

MIT — see `LICENSE` at the root of the repository.