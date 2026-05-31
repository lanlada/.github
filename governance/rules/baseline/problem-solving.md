---
description: Fix at root cause; never suppress a symptom
---

# Problem Solving

Trace every problem to its deepest origin and fix it there. Suppressing or bypassing a symptom is not a fix — it leaves a trap for the next person and the next bug.

## Don't

- Add `// eslint-disable` or `// eslint-disable-next-line` (also prohibited by `no-code-comments`)
- Add `// @ts-ignore` or `// @ts-expect-error` (also prohibited by `no-code-comments`)
- Use `as unknown as X` casts to escape a type error
- Use `!` non-null assertion to silence a null check
- Add a package to `onlyBuiltDependencies` without understanding why the build script runs
- Remove a failing test instead of fixing the cause
- Catch an error and swallow it silently

## Do

- Read the full error message
- Identify which layer owns the problem (dependency, config, code, type, runtime)
- Fix at that layer — not one layer above it
- When the root fix is blocked by an upstream bug, link the upstream issue in the PR description and document the workaround there

## Exceptions

- None — every workaround needs a tracked upstream cause and a PR-level explanation, not silent suppression
