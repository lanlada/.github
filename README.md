# lanlada/.github

The GitHub-native runtime for the `lanlada` organization. This repository holds only what GitHub serves or runs directly:

- `profile/README.md` — the organization profile.
- `.github/ISSUE_TEMPLATE/*` and `.github/PULL_REQUEST_TEMPLATE.md` — organization default templates for repositories that do not define their own.
- `.github/workflows/reusable-*.yml` — reusable workflows, referenced as `uses: lanlada/.github/.github/workflows/<file>@<ref>`.
- `.github/scripts/*` and `.github/common-actions/*` — the scripts and composite action those reusable workflows call.

This repository is public because GitHub serves organization default community health files only from a public `.github` repository.

## Governance data and tooling live elsewhere

The label taxonomy, baseline rules, repository metadata, and the sync scripts that apply them are **not** here. They live in the private repository **`lanlada/lanlada-governance`**, because they are organization data and tooling rather than GitHub-native files. That repository is the source of truth for:

- the label taxonomy (`type:`, `priority:`, `status:`, `area:`) and its baseline plus stack overlays,
- the baseline `.claude/rules` and their stack overlays,
- repository metadata (`description`, `topics`),
- the `sync-labels.sh`, `sync-rules.sh`, and `sync-repo-meta.sh` scripts.

## Onboarding a repository

1. Remove local issue templates so the repository uses the organization defaults here. Keep a stack-specific pull request template locally.
2. Add caller workflows that reference the reusable workflows here.
3. Apply labels, rules, and metadata using the sync scripts in `lanlada/lanlada-governance`.
4. Generate the baseline `CODEOWNERS` and `dependabot.yml` shapes into the repository.

## Constraints

- GitHub Actions billing must be restored before any workflow runs green.
- The organization is on GitHub Free with private repositories, so branch protection is unavailable until a plan upgrade.
- This repository must remain public for default community health files to apply.
