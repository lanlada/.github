# lanlada Organization Governance

This repository is the governance source of truth for the `lanlada` organization. It standardizes how every repository is configured so that any repository can be pattern-matched against one known structure.

## Two control planes

**GitHub-native defaults.** This repository holds the organization profile, default issue and pull request templates, and reusable workflows. Default templates apply to any repository that does not define its own local template. Reusable workflows are referenced by consumer repositories through `uses: lanlada/.github/.github/workflows/<file>@<ref>`. This repository is public because GitHub serves organization default community health files only from a public `.github` repository.

**Native sync.** Labels and a narrow set of repository metadata (`description`, `homepage`, `topics`) are applied by native sync scripts under `governance/scripts/`. These scripts do not configure branch protection, rulesets, environments, or secrets.

Probot Settings is intentionally not used. Branch protection is deferred until the organization upgrades from GitHub Free; at that point GitHub-native organization rulesets are the first choice.

## Baseline and overlay

Configuration that does not depend on a repository's technology stack is **baseline** and lives here. Configuration that depends on the stack (Next.js or NestJS) is an **overlay** that lives as a short file in the consumer repository. The precise split is recorded in `governance/README.md`.

## Label taxonomy

Every label belongs to exactly one prefixed category: `type:`, `priority:`, `status:`, or `area:`. The full reference is in `governance/README.md`. The enumerated label content is applied in the label rollout sub-project.

## Onboarding a repository

1. Remove local issue and pull request templates so the repository uses the organization defaults.
2. Add caller workflows that reference the reusable workflows here.
3. Apply the baseline labels plus the stack overlay using the governance sync script.
4. Generate the baseline `CODEOWNERS` and `dependabot.yml` shapes into the repository.

## Sub-projects

1. Foundation — this repository and its contracts (complete when this README and `governance/README.md` exist).
2. Label taxonomy rollout.
3. Templates moved to organization defaults.
4. Reusable workflows.
5. Rules distribution and repository metadata sync.
6. Scaffolding the empty repositories.

Design notes and implementation plans for each sub-project are kept as working artifacts outside this repository; only the resulting deliverables are tracked here.

## Constraints

- GitHub Actions billing must be restored before any workflow runs green.
- The organization is on GitHub Free with private repositories, so branch protection is unavailable until a plan upgrade.
- This repository must remain public for default community health files to apply.
