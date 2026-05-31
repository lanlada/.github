---
description: Lint config is locked to the company template; do not invent or edit rules
---

# Lint Rules Locked

ESLint, Prettier, commitlint, and lint-staged configuration are owned by the company template repo and copied here verbatim. `.claude/hooks/protect-files.sh` blocks edits to `eslint.config.mjs` and `eslint/**`. Work around a strict rule by changing the source code, not the rule.

## Don't

- Edit `eslint.config.mjs` or `eslint/**` to silence a rule for your own code
- Add `// eslint-disable` or `// @ts-ignore` to bypass a finding — see `problem-solving` and `no-code-comments`
- Invent custom plugin rules
- Reorder, rename, or remove fields in the company-template eslint files

## Do

- Refactor source code to satisfy the strict rule
- Document any non-obvious codebase pattern that exists only to satisfy lint — keep that note in `CLAUDE.md` under "Lint Workarounds in This Codebase"
- File an upstream change in the company template repo when a rule is genuinely wrong, then sync the updated config

## Exceptions

- Plumbing changes (adapting file globs to new directories) are acceptable when the rule body is unchanged — that adapts existing rules to new paths, it does not invent new rules
