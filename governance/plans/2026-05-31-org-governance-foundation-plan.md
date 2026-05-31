# Organization Governance Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up `lanlada/.github` as the public organization governance source of truth, scaffolded to the agreed structure and carrying the canonical standard documentation, with no per-dimension content rolled out.

**Architecture:** Create one public repository, `lanlada/.github`. Populate it with the directory skeleton from the design (profile, default-template and reusable-workflow placeholders, and a `governance/` tree), then author three documents that record the governance model and contracts: a root README (the standard), `governance/README.md` (the baseline/overlay and taxonomy contract), and `profile/README.md` (the org profile). Label content, template migration, workflow conversion, rules distribution, and repository scaffolding are explicitly out of scope and owned by later sub-projects.

**Tech Stack:** GitHub CLI (`gh`), git, Markdown. No application runtime, no GitHub Actions execution (so the organization Actions billing failure does not block this sub-project).

**Reference spec:** `docs/governance/specs/2026-05-31-org-governance-foundation-design.md` (in `lanlada-platform-backoffice-web`).

---

## Scope and constraints

- This plan operates on a new repository `lanlada/.github`. All file paths in tasks are relative to that repository's root unless stated otherwise.
- The repository must be **public** so GitHub serves organization default community health files (design Constraint 3).
- This sub-project does **not** roll out labels, migrate templates, convert workflows, distribute rules, scaffold repositories, or configure branch protection (design Non-goals).
- `git push` may be blocked by a local hook for the agent. Where a step pushes, the operator runs the push (for example by prefixing the command with `!` in the session) if the agent is blocked.
- Verification uses structural and lint checks, not unit tests, because this sub-project produces repository scaffolding and documentation rather than runtime code.

## File structure (target repository `lanlada/.github`)

```
lanlada/.github
├── README.md                        # canonical standard: how org governance works
├── profile/README.md                # org public profile page
├── .github/
│   ├── ISSUE_TEMPLATE/.gitkeep      # placeholder; populated in sub-project 3
│   └── workflows/.gitkeep           # placeholder; populated in sub-project 4
└── governance/
    ├── README.md                    # baseline/overlay contract + taxonomy reference
    ├── labels/.gitkeep              # placeholder; populated in sub-project 2
    ├── rules/.gitkeep               # placeholder; populated in sub-project 5
    └── scripts/.gitkeep             # placeholder; populated in sub-project 2 and 5
```

Each document has one responsibility: the root README explains the model to a newcomer, `governance/README.md` is the precise contract an implementer checks against, and `profile/README.md` is the public org face. Placeholders mark where later sub-projects add content so the structure is legible before it is filled.

---

### Task 1: Create and clone the public `lanlada/.github` repository

**Files:**

- Create: the repository `lanlada/.github` (remote) and a local clone

- [ ] **Step 1: Confirm the repository does not already exist**

Run: `gh repo view lanlada/.github 2>&1 | head -1`
Expected: an error line containing `Could not resolve to a Repository with the name 'lanlada/.github'`. If the repository already exists, stop and reconcile with the operator before continuing.

- [ ] **Step 2: Create the repository as public with a placeholder description**

Run:

```bash
gh repo create lanlada/.github \
  --public \
  --description "Organization governance source of truth: default community health files, reusable workflows, and governance assets." \
  --clone
```

Expected: the command reports the repository created and clones it into `./.github`.

- [ ] **Step 3: Verify the clone and visibility**

Run:

```bash
cd .github
gh repo view lanlada/.github --json visibility,name --jq '{name: .name, visibility: .visibility}'
```

Expected: `{"name":".github","visibility":"PUBLIC"}`.

- [ ] **Step 4: Confirm a clean default branch**

Run: `git -C .github branch --show-current`
Expected: `main` (or the org default). Record the branch name; later push steps use it.

---

### Task 2: Scaffold the directory structure with placeholders

**Files:**

- Create: `.github/ISSUE_TEMPLATE/.gitkeep`
- Create: `.github/workflows/.gitkeep`
- Create: `governance/labels/.gitkeep`
- Create: `governance/rules/.gitkeep`
- Create: `governance/scripts/.gitkeep`

- [ ] **Step 1: Create the directories and placeholder files**

Run from the repository root:

```bash
mkdir -p .github/ISSUE_TEMPLATE .github/workflows governance/labels governance/rules governance/scripts profile
touch .github/ISSUE_TEMPLATE/.gitkeep .github/workflows/.gitkeep governance/labels/.gitkeep governance/rules/.gitkeep governance/scripts/.gitkeep
```

- [ ] **Step 2: Verify the tree matches the plan**

Run: `find . -path ./.git -prune -o -type f -print | sort`
Expected output (order may vary):

```
./.github/ISSUE_TEMPLATE/.gitkeep
./.github/workflows/.gitkeep
./governance/labels/.gitkeep
./governance/rules/.gitkeep
./governance/scripts/.gitkeep
```

- [ ] **Step 3: Commit the scaffold**

Run:

```bash
git add -A
git commit -m "setup(governance): scaffold org .github source-of-truth structure"
```

Expected: one commit recording five `.gitkeep` files.

---

### Task 3: Write the root `README.md` (canonical standard)

**Files:**

- Create: `README.md`

- [ ] **Step 1: Write the file**

Create `README.md` with exactly this content:

```markdown
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

## Constraints

- GitHub Actions billing must be restored before any workflow runs green.
- The organization is on GitHub Free with private repositories, so branch protection is unavailable until a plan upgrade.
- This repository must remain public for default community health files to apply.
```

- [ ] **Step 2: Lint the Markdown for broken structure**

Run: `npx --yes markdownlint-cli2 "README.md" 2>&1 | tail -20`
Expected: no errors, or only line-length advisories. Fix any structural error (broken headings, malformed lists) before continuing.

- [ ] **Step 3: Commit**

Run:

```bash
git add README.md
git commit -m "docs(governance): add canonical organization standard readme"
```

---

### Task 4: Write `governance/README.md` (contract reference)

**Files:**

- Create: `governance/README.md`

- [ ] **Step 1: Write the file**

Create `governance/README.md` with exactly this content:

```markdown
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
```

- [ ] **Step 2: Lint the Markdown**

Run: `npx --yes markdownlint-cli2 "governance/README.md" 2>&1 | tail -20`
Expected: no structural errors.

- [ ] **Step 3: Commit**

Run:

```bash
git add governance/README.md
git commit -m "docs(governance): add baseline overlay and label taxonomy contract"
```

---

### Task 5: Write `profile/README.md` (organization profile)

**Files:**

- Create: `profile/README.md`

- [ ] **Step 1: Write the file**

Create `profile/README.md` with exactly this content:

```markdown
# lanlada

The lanlada platform: a backoffice and tenant-facing product suite built on Next.js and NestJS.

Repositories in this organization follow a single governance standard. The standard, its contracts, and the label taxonomy are documented in this organization's `.github` repository.
```

- [ ] **Step 2: Lint the Markdown**

Run: `npx --yes markdownlint-cli2 "profile/README.md" 2>&1 | tail -20`
Expected: no structural errors.

- [ ] **Step 3: Commit**

Run:

```bash
git add profile/README.md
git commit -m "docs(governance): add organization profile readme"
```

---

### Task 6: Set repository metadata and publish

**Files:**

- Modify: repository metadata for `lanlada/.github` (remote)

- [ ] **Step 1: Set topics**

Run:

```bash
gh repo edit lanlada/.github \
  --add-topic governance \
  --add-topic organization \
  --add-topic standards
```

Expected: the command reports the repository updated.

- [ ] **Step 2: Push all commits to the default branch**

Run: `git push origin <default-branch>` (use the branch recorded in Task 1, Step 4). If the agent is blocked by a local push hook, the operator runs this command.
Expected: all foundation commits land on the remote default branch.

- [ ] **Step 3: Verify the profile renders**

Open `https://github.com/lanlada` in a browser.
Expected: the organization profile shows the text from `profile/README.md`.

---

### Task 7: Verify against the spec acceptance criteria

**Files:**

- None (verification only)

- [ ] **Step 1: Verify the structure exists on the remote**

Run:

```bash
gh api repos/lanlada/.github/git/trees/HEAD?recursive=1 \
  --jq '.tree[].path' | sort
```

Expected: includes `README.md`, `profile/README.md`, `.github/ISSUE_TEMPLATE/.gitkeep`, `.github/workflows/.gitkeep`, `governance/README.md`, `governance/labels/.gitkeep`, `governance/rules/.gitkeep`, `governance/scripts/.gitkeep`.

- [ ] **Step 2: Verify visibility is public**

Run: `gh repo view lanlada/.github --json visibility --jq .visibility`
Expected: `PUBLIC`.

- [ ] **Step 3: Confirm the contract documents the deferred and excluded items**

Run:

```bash
grep -c "Probot Settings is intentionally not used" README.md
grep -c "branch protection is deferred\|Branch protection is deferred\|branch protection is unavailable" README.md
```

Expected: each grep returns at least `1`, confirming the foundation records that Probot is excluded and branch protection is deferred (acceptance criterion 8).

- [ ] **Step 4: Confirm the taxonomy contract lists exactly the four prefixed categories**

Run: `grep -E "^- \`(type|priority|status|area):\`" governance/README.md | wc -l`Expected:`4` (acceptance criterion 5).

- [ ] **Step 5: Record completion**

The foundation is complete when Steps 1 through 4 pass. Label rollout (sub-project 2) is the next plan.

---

## Self-review notes

- **Spec coverage.** Architecture (source of truth, two control planes, public requirement) is implemented by Tasks 1, 3, 4. Baseline/overlay contract and label taxonomy structure are implemented by Task 4. Decomposition and constraints are recorded in Task 3's README. Acceptance criteria 1, 2, 5, 7, 8 are verified in Task 7; criteria 3, 4, 6 concern reusable workflows and label content owned by later sub-projects and are intentionally not verified here.
- **Non-goals respected.** No label content, template migration, workflow conversion, rules distribution, repository scaffolding, or branch protection is performed; placeholders mark those locations.
- **No placeholders in steps.** Every document step contains the full file content; every verification step contains an exact command and expected output.

```

```
