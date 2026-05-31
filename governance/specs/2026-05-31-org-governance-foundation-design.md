# Organization Governance Foundation — Design

## Summary

This document specifies the foundation for organization-wide governance across the `lanlada` GitHub organization. It establishes a single source of truth, a baseline-versus-overlay model that accommodates two technology stacks (Next.js and NestJS), and a unified label taxonomy. The foundation is the first of six sub-projects; it defines the contracts and structure that the remaining sub-projects implement against. It does not roll out the full content of any single dimension — that work is sequenced into later sub-projects.

## Background

The `lanlada` organization contains five repositories in two stacks. Two are mature and carry parallel-but-divergent governance: `lanlada-platform-backoffice-web` (Next.js) and `lanlada-platform-api` (NestJS). Three are empty repositories awaiting their first commit: `lanlada-tenant-booking-web`, `lanlada-tenant-backoffice-web`, and `lanlada-platform-official-web` (all Next.js).

Governance drifted because each repository was configured independently. The same defect appears in three forms: labels were created ad hoc per repository, the `github-templates` rule mandates a backend-flavored area taxonomy (`area:api`, `area:migrations`) while the Next.js repository's `labeler.yml` uses a frontend taxonomy (`area:app`, `area:components`), and the rule documents and the live repository configuration disagree on which labels exist at all. The labels in every repository were reset to the GitHub default set as a clean slate before this design.

The objective is consistency and symmetry across the organization at a professional, enterprise standard: a reader or an agent should be able to pattern-match any repository against a single known structure.

## Objective

Establish `lanlada/.github` as the organization governance source of truth, operating through GitHub-native defaults and native sync scripts, with a baseline-versus-overlay model and a unified, prefixed label taxonomy that every repository shares.

## Architecture

`lanlada/.github` is the organization governance source of truth. It provides two separate control planes.

### Layer A — GitHub-native defaults

```
lanlada/.github
├── profile/README.md
├── .github/
│   ├── ISSUE_TEMPLATE/*.yml
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/reusable-*.yml
└── governance/
    ├── labels/{baseline,overlay-nextjs,overlay-nestjs}.yml
    ├── rules/
    └── scripts/
        ├── sync-labels.sh       (sub-project 2)
        └── sync-repo-meta.sh    (sub-project 5)
```

- `profile/README.md` renders the organization profile.
- `.github/ISSUE_TEMPLATE/*.yml` and `.github/PULL_REQUEST_TEMPLATE.md` act as organization default templates. They apply only to repositories that do not define their own local templates.
- `.github/workflows/reusable-*.yml` expose reusable workflows through `workflow_call`. A consumer repository invokes one with `uses: lanlada/.github/.github/workflows/<file>@<ref>`, and the change takes effect on that repository's next workflow run that references the pinned ref.

A change to `lanlada/.github` does not propagate to every repository instantly. Template changes affect only repositories without their own templates. Reusable workflow changes affect a consumer when its next run resolves the pinned ref (`@main`, `@v1`, or a SHA).

`lanlada/.github` must be public. GitHub serves organization default community health files only from a public `.github` repository; a private one does not provide defaults. The files held there are templates and CI scaffolding and carry no secrets, so public visibility is acceptable. Application source remains in the private repositories.

### Layer B — native sync

- `sync-labels.sh` applies the label taxonomy. A separate `sync-repo-meta.sh`, introduced in sub-project 5, applies a narrow set of repository metadata limited to `description`, `homepage`, and `topics`. Both explicitly exclude branch protection, rulesets, environments, and secrets.
- Each script is limited to the scopes it implements. Neither is a branch-protection mechanism.
- While the GitHub Actions billing failure blocks workflow execution, the sync scripts run as local manual execution by an organization administrator from a workstation, not through a workflow. Sub-project 2 proceeds on local execution and does not wait for the billing fix.

### Excluded: Probot Settings

Probot Settings and its `_extends` inheritance mechanism are intentionally excluded from the foundation. `_extends` is a Probot convention, not a GitHub-native feature, and it requires installing and granting a third-party GitHub App access to the repositories. The primary reason to adopt it would be branch-protection-as-code, and branch protection is unavailable on the current plan regardless of tooling (see Constraints). Do not install Probot Settings for branch protection while the organization is on GitHub Free with private repositories. When the organization upgrades, use GitHub-native organization rulesets first.

## Baseline versus Overlay

The decision rule: if a surface's logic does not depend on the stack, it is baseline and lives in `lanlada/.github`; if it depends on the stack, it is an overlay that lives as a short file in the consumer repository.

| Surface             | Baseline (identical across repos)                                                                                                                                | Overlay (differs by stack)                                                                             |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| Rules               | conventional-commits, deploy-branches, enterprise-voice, github-templates, issue-writing, lint-rules-locked, no-code-comments, problem-solving, token-efficiency | `component-scaffolding` (Next.js) / `module-layout` (NestJS)                                           |
| Workflows           | pr-validate, issue-validate, sca, security-audit, stale (as reusable workflows)                                                                                  | ci (build and test differ), deploy (NestJS has a deploy workflow; web uses Vercel), dast (NestJS only) |
| Templates           | ISSUE_TEMPLATE/\*, PULL_REQUEST_TEMPLATE.md                                                                                                                      | —                                                                                                      |
| Generated shapes    | CODEOWNERS shape, dependabot shape                                                                                                                               | —                                                                                                      |
| Labels              | type, priority, status                                                                                                                                           | area                                                                                                   |
| Scripts             | check-\*.sh embedded inside the reusable workflows                                                                                                               | —                                                                                                      |
| Secrets / Variables | naming convention and required variable names                                                                                                                    | actual environment names and stack-specific values                                                     |

For secrets and variables, the baseline defines naming only. Actual values remain in each consumer repository or environment. Reusable workflows receive them through `secrets: inherit` or declared inputs against the agreed names.

A consumer repository wires a baseline workflow through a thin caller:

```yaml
jobs:
  pr-validate:
    uses: lanlada/.github/.github/workflows/reusable-pr-validate.yml@main
```

CODEOWNERS and Dependabot are baseline shapes to be copied or generated into consumer repositories; they are not organization default community health files. GitHub does not serve `CODEOWNERS` or `dependabot.yml` from `lanlada/.github` the way it serves issue and pull request templates, so each repository carries its own generated copy against the baseline shape. The transport that distributes these generated shapes is the same mechanism used for rules distribution, decided in sub-project 5.

## Unified Label Taxonomy

The taxonomy has four prefixed categories. Every label carries its category prefix so that the four planes never collide and search stays predictable.

- `type:` — baseline. Values mirror the commitlint type enum: `type:feat`, `type:fix`, `type:refactor`, `type:chore`, `type:docs`, `type:ci`, `type:perf`, `type:setup`, `type:build`, `type:revert`, `type:style`, `type:test`, `type:incident`, `type:epic`. The value after the colon equals the commit type, which preserves the issue-to-PR-to-commit link that supports automated release notes.
- `priority:` — baseline. `priority:high`, `priority:medium`, `priority:low`.
- `status:` — baseline, automation-owned. `status:blocked`, `status:needs-triage`, `status:needs-info`, `status:needs-issue-title-fix`, `status:needs-pr-title-fix`, `status:stale`. Automation owns these by default; a person adds or removes them only when triaging intentionally.
- `area:` — overlay, repo/stack-owned. The org baseline defines only the shared areas: `area:deps`, `area:ci`, `area:config`, `area:docs`. Stack overlays add their own: Next.js adds `area:app`, `area:components`, `area:lib`, `area:styles`, `area:public`; NestJS adds `area:api`, `area:modules`, `area:migrations`, and similar.

The foundation fixes the categories, the prefix convention, and the baseline-versus-overlay split. The exhaustive per-category enumeration is finalized in the label rollout sub-project.

## Decomposition and Sequencing

The full initiative is too large for one specification. It decomposes into six sub-projects, each with its own spec, plan, and acceptance criteria.

1. Foundation — this document. Source of truth, control planes, baseline/overlay contract, taxonomy structure, reusable-workflow strategy.
2. Label taxonomy rollout — the sync script and the full label content applied to every repository.
3. Templates to `lanlada/.github` — move issue and PR templates to the organization defaults and remove local copies so repositories inherit them.
4. Reusable workflows to `lanlada/.github` — convert baseline workflows to `workflow_call` and wire consumer caller overlays.
5. Rules distribution and repository metadata sync — distribute the baseline rules and sync `description`, `homepage`, and `topics`. The transport mechanism for rules distribution (copy script, generated files, submodule, or package) is intentionally deferred to this sub-project and is not decided in the foundation.
6. Scaffold the three empty repositories — apply baseline plus the Next.js overlay to `lanlada-tenant-booking-web`, `lanlada-tenant-backoffice-web`, and `lanlada-platform-official-web`.

Rules distribution and repository scaffolding are separate sub-projects because their acceptance criteria differ: one verifies governance content propagation, the other verifies a repository boots from zero against the standard.

## Non-goals

The foundation defines contracts and structure only. It does not perform any of the following; each is owned by a later sub-project:

- It does not implement the final label list.
- It does not migrate templates.
- It does not convert workflows.
- It does not scaffold repositories.
- It does not enforce branch protection.

## Constraints

Known platform constraints recorded for every downstream sub-project:

1. GitHub Actions billing currently blocks CI execution organization-wide. Workflow architecture can be specified, but a green CI run requires the billing failure to be resolved first. Reusable workflow files can be authored and wired before billing is fixed; runtime validation is blocked until billing is restored.
2. The organization is on GitHub Free with private repositories, which blocks branch protection. The branch-protection API returns `403: Upgrade to GitHub Pro or make this repository public`. Branch protection is deferred until the organization upgrades the plan or repositories become public. When that happens, GitHub-native organization rulesets are the first choice.
3. `lanlada/.github` must be public for organization default community health files to apply.
4. Probot Settings is intentionally excluded from the foundation path. Native GitHub defaults plus native sync scripts are the operating model.

## Acceptance Criteria

- Given `lanlada/.github`, when inspected, then it contains the planned structure for profile, default templates, reusable workflows, governance labels, rules, and sync scripts.
- Given `lanlada/.github` is public and any consumer repository has no local issue or pull request template, then GitHub serves the organization default template from `lanlada/.github`.
- Given a baseline workflow, when inspected, then it is defined as a reusable workflow with `on.workflow_call`.
- Given a consumer workflow, when inspected, then it calls the reusable workflow through `uses: lanlada/.github/.github/workflows/<file>@<ref>`.
- Given the label taxonomy, when inspected, then every label belongs to exactly one prefixed category: `type:`, `priority:`, `status:`, or `area:`.
- Given `area:` labels, when inspected, then shared areas are baseline and stack-specific areas are overlays.
- Given the native sync script scope, when inspected, then it handles labels and narrow repository metadata only, and does not touch branch protection, rulesets, environments, or secrets.
- Given the organization plan constraint, when inspected, then branch protection is documented as deferred and Probot Settings is not part of the foundation path.

## Risks

- Until the plan upgrade lands, governance enforcement rests on local Husky hooks and advisory CI status checks; the checks cannot be made required for merge without branch protection. This is a known gap, not a defect in the design.
- Moving templates to organization defaults only takes effect for a repository once its local templates are removed. A repository that retains a local template silently keeps its old copy. The templates sub-project must remove local copies as part of its definition of done.
- Reusable workflows pinned to `@main` shift behavior on every change to `lanlada/.github`. Tagging a release ref (`@v1`) is the mitigation when stability is required.
- The public `lanlada/.github` repository exposes governance and CI structure. This is acceptable because it holds no secrets or application source, but workflow content must not embed sensitive endpoint names, tokens, or private infrastructure details.

## Open Questions

- The ref-pinning policy for reusable workflows (`@main` for fast propagation versus `@v1` for stability) is decided in the reusable-workflows sub-project, not here.
- Whether a tracking issue and milestone structure mirrors the six sub-projects is a process decision for the rollout, deferred to the label rollout sub-project where the first cross-repo work begins.
