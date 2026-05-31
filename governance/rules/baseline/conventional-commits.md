---
description: Commit messages follow Conventional Commits enforced by commitlint
---

# Conventional Commits

Every commit message follows `<type>(<scope>): <subject>` with an optional body wrapped at 72 columns. `commitlint` enforces the format in the pre-commit hook, and `husky` plus `lint-staged` may reformat staged files in-flight — re-stage and re-commit when that happens.

## Don't

- Omit the scope (commitlint rejects)
- Exceed 72 characters in the subject
- Use uppercase letters in type, scope, or subject
- End the subject with a period
- Skip the blank line between subject and body
- Bypass the hook with `--no-verify` or `--no-gpg-sign`

## Do

- Pick a type from `build` `chore` `ci` `docs` `feat` `fix` `perf` `refactor` `revert` `setup` `style` `test`
- Use a single-word lowercase scope identifying the area (`runtime`, `config`, `storefront`, `health`)
- Write the subject in imperative mood ("add", "drop", "fix" — not "added")
- Explain the why in the body when the change is non-obvious
- Append `Closes #N` on its own line to auto-close an issue when the PR merges
- Re-stage and re-commit if `lint-staged` modifies files during the commit

## Exceptions

- None — every commit on every branch follows this format
