---
description: Deploy branches dev/uat/main are PR-only; commits and pushes are blocked locally
---

# Deploy Branches

`dev`, `uat`, and `main` are the three branches that map to live environments. Treat them as artifacts of merged PRs — never as workspaces. All work happens on `feature/*` or `hotfix/*` and lands through a PR. Husky `pre-commit` and `pre-push` block commits and pushes on deploy branches; the `pairing` job in `.github/workflows/pr-validate.yml` rejects any PR whose base/head combination falls outside the promotion path.

Allowed PR pairings:

- any non-deploy branch → `dev` (covers `feature/*`, `fix/*`, dependabot, ticket-ID branches, etc.)
- `dev` → `uat`
- `uat` → `main`
- `hotfix/*` → `main`

A hotfix back-port follows the normal path: cherry-pick the hotfix commit into a new branch from `dev`, then PR → `dev` → `uat` → `main`.

## Don't

- Commit while `HEAD` is `dev`, `uat`, or `main`
- Push to `dev`, `uat`, or `main` directly, force or otherwise
- Develop on a deploy branch — rename or branch off immediately
- Run `git merge`, `git rebase`, or `git cherry-pick` to update a deploy branch from a developer machine
- Bypass husky hooks with `--no-verify` or `--no-gpg-sign`
- Use `workflow_dispatch` to deploy when a PR merge would do the same

## Do

- Branch from the env you target: `git checkout <env> && git pull && git checkout -b feature/<topic>`
- Promote via PR: `feature/*` → `dev` → `uat` → `main`
- Run hotfixes as `hotfix/*` → PR to `main`, then back-port to `uat` and `dev`
- Verify CI locally on the feature branch before opening the PR (`pnpm typecheck && pnpm lint && pnpm test && pnpm build`)
- Squash-merge through the GitHub UI so the merge commit is server-side and the audit trail is preserved
- Follow `github-templates` for pull request title, body, label, milestone, and reviewer requirements

## Exceptions

- None
