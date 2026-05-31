# Governance Contract

This document is the precise contract an implementer checks against. It is the reference for the baseline/overlay split and the label taxonomy.

## Decision rule

If a surface's logic does not depend on the stack, it is baseline and lives in `lanlada/.github`. If it depends on the stack, it is an overlay that lives as a short file in the consumer repository.

## Baseline versus overlay

| Surface               | Baseline (identical across repos)                                                                                                                                | Overlay (differs by stack)                                    |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| Rules                 | conventional-commits, deploy-branches, enterprise-voice, github-templates, issue-writing, lint-rules-locked, no-code-comments, problem-solving, token-efficiency | component-scaffolding (Next.js) / module-layout (NestJS)      |
| Workflows             | pr-validate, issue-validate, sca, security-audit, stale (as reusable workflows)                                                                                  | ci, deploy (NestJS only; web uses Vercel), dast (NestJS only) |
| Templates             | ISSUE_TEMPLATE, PULL_REQUEST_TEMPLATE                                                                                                                            | none                                                          |
| Generated shapes      | CODEOWNERS shape, dependabot shape                                                                                                                               | none                                                          |
| Labels                | type, priority, status                                                                                                                                           | area                                                          |
| Scripts               | check scripts embedded in reusable workflows                                                                                                                     | none                                                          |
| Secrets and variables | naming convention and required variable names                                                                                                                    | actual environment names and stack-specific values            |

Templates are served by GitHub as organization defaults. Generated shapes (`CODEOWNERS`, `dependabot.yml`) are not served as defaults; each repository carries its own copy generated against the baseline shape, distributed by the same mechanism as rules.

## Label taxonomy

Every label carries its category prefix so the four planes never collide.

- `type:` — baseline. Values mirror the commitlint type enum: `type:feat`, `type:fix`, `type:refactor`, `type:chore`, `type:docs`, `type:ci`, `type:perf`, `type:setup`, `type:build`, `type:revert`, `type:style`, `type:test`, `type:incident`, `type:epic`.
- `priority:` — baseline. `priority:high`, `priority:medium`, `priority:low`.
- `status:` — baseline, automation-owned. `status:blocked`, `status:needs-triage`, `status:needs-info`, `status:needs-issue-title-fix`, `status:needs-pr-title-fix`, `status:stale`. Automation owns these by default; a person changes them only when triaging intentionally.
- `area:` — overlay, repo and stack owned. The baseline defines only the shared areas: `area:deps`, `area:ci`, `area:config`, `area:docs`. Next.js repositories add `area:app`, `area:components`, `area:lib`, `area:styles`, `area:public`. NestJS repositories add `area:api`, `area:modules`, `area:migrations`.

The category set, prefix convention, and ownership rules above are fixed by the foundation. The exhaustive enumeration per category is confirmed in the label rollout sub-project.
