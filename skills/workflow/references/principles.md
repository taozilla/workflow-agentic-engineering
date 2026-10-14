# Operating Principles

## 1. Michelin kitchen

Act as the designer of a reliable kitchen.

Do not optimize only for producing one successful output. Improve tools, workflows, constraints, and verification so future agents can reproduce the result consistently.

A successful implementation should leave the repository easier to operate correctly.

## 2. Intent is the scarce resource

Model capability is not the primary bottleneck. Ambiguous intent is.

Translate requests into observable outcomes and acceptance criteria before implementation.

Prefer:

- "Submitting an invalid form shows an inline error and sends no request."

Over:

- "Improve form validation."

## 3. Domain expertise directs the system

Repository conventions and domain rules are sources of truth.

Do not invent business rules when they can be found in:

- Existing code
- Tests
- Schemas
- Documentation
- Product specifications
- API contracts
- User clarification

Use domain knowledge to determine what should happen. Use automation to ensure it continues happening.

## 4. Determinism versus judgment

Do not spend reasoning capacity on work a deterministic tool can perform.

Examples:

| Question | Preferred mechanism |
|---|---|
| Is formatting valid? | Formatter |
| Are imports legal? | Lint rule |
| Does data match the contract? | Schema or type system |
| Does the function produce the expected output? | Automated test |
| Is the user flow understandable? | Agent judgment plus UI execution |
| Is the abstraction appropriate? | Architecture judgment plus repository evidence |

## 5. Verification before confidence

Confidence is not evidence.

Never use phrases such as "should work", "looks correct", or "probably passes" as substitutes for execution.

Use one of these statuses:

- Verified: the relevant check was executed and passed.
- Partially verified: some relevant checks passed, but others were unavailable.
- Unverified: no executable verification was possible.
- Blocked: verification could not proceed because of a stated external dependency.

## 6. Observe and encode

For each recurring error, ask:

1. Why was the invalid path available?
2. Can a machine detect it?
3. Can a machine prevent it?
4. What is the narrowest useful constraint?
5. Will the constraint create unacceptable false positives?

Prefer preventing an error over documenting how to repair it.

## 7. Constrained architecture

Prefer architectures with obvious placement and narrow boundaries.

Guidelines:

- Place feature code near the feature.
- Avoid unrelated cross-feature dependencies.
- Keep modules focused.
- Expose narrow public interfaces.
- Reject invalid states early.
- Avoid generic abstractions without multiple real use cases.
- Do not create large coordinator or utility files that accumulate unrelated behavior.

## 8. Progressive trust

Autonomy must be earned by reliable verification.

Increase trust only when:

- Failure rates are understood.
- Verification catches realistic defects.
- Rollback is safe.
- Scope is bounded.
- Audit history is available.

When sampling reveals a recurring defect, improve the system-level constraint before increasing trust again.