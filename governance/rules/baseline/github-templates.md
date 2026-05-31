---
description: Issues, PRs, branches, and labels follow fixed templates for symmetry
---

# GitHub Templates

Every issue uses one of the templates in `.github/ISSUE_TEMPLATE/`. Every PR uses `.github/PULL_REQUEST_TEMPLATE.md`. Every branch follows `<issue-number>-<kebab-case>`. Every issue and PR carries at least one type label. Symmetry lets reviewers and LLM agents pattern-match without prior context.

## Don't

- Skip a template section that has content to fill
- Invent new sections outside the template
- Open a PR whose body has no `Closes #N` line — CI enforces at least one closing reference per PR; if the work has no tracking issue, open one first
- Tick a Test plan box for a command that was not actually run
- Open an issue or PR with no labels
- Use a branch name that does not start with an issue number

## Do

- Pick the issue template closest to the work: `task.yml` (setup, refactor, or epic), `bug_report.yml`, `feature_request.yml`, `incident.yml`
- Follow the canonical pull request sections in order: Summary, Type of Change, Test Plan, Post-Deploy Verification, Architecture Compliance, conditional sections, Risks
- Use exact commands and expected output in Acceptance Criteria. Vague prose is not acceptable.
- Apply one type label per issue and PR: `type:feat`, `type:fix`, `type:refactor`, `type:chore`, `type:docs`, `type:ci`, `type:perf`, `type:setup`, `type:incident`, or `type:epic`
- Apply at least one area label per PR (`area:*`) — the path-based labeler attaches these automatically based on changed paths, using the area set defined for the repository's stack
- Apply a priority label (`priority:high`, `priority:medium`, or `priority:low`) to every issue. The four issue templates under `.github/ISSUE_TEMPLATE/` do not pre-fill priority because severity varies; the issue author selects the label at creation, or a triager adds it during processing. Incident issues already carry `priority:high` by template default.
- Attach a milestone when the work belongs to one — see the **Milestones** section below
- Assign every issue to `joetakara` and `nextfridaydeveloper` at creation time. Pass both names as `--assignee` flags to `gh issue create`, or set them through the GitHub UI sidebar. The issue templates under `.github/ISSUE_TEMPLATE/` already pre-fill both names through the `assignees:` frontmatter field, so issues opened through the UI carry the assignees automatically; CLI-opened issues must add the flags explicitly. Unassigned issues hide from the My Issues view and weaken the audit trail.
- Request a reviewer on every pull request. Use `gh pr create --reviewer nextfridaydeveloper` (`joetakara` cannot self-review). The repository carries a comprehensive `.github/CODEOWNERS` mapping that names both collaborators on every path, but CODEOWNERS auto-request fires only when branch protection requires review from code owners, and branch protection is gated behind the GitHub Pro plan that this private repository does not currently hold. Until the plan tier supports the auto-request, the reviewer is added manually on every pull request.
- Set the Issue Type when the organisation has enabled Custom Issue Types. Use `gh issue create --type Task` (or `Bug`, `Feature`, `Incident`, `Epic`). The repository's `repos/<owner>/<repo>/issue-types` endpoint currently returns `Not Found`, so the convention is dormant until an organisation administrator enables Custom Issue Types at `https://github.com/organizations/<org>/settings/issue-types`. The issue templates will also gain a `type:` frontmatter entry once the types exist.
- Use branch names like `1-setup-project`, `42-availability-resolver`
- Verify the pull request base/head pairing matches the promotion path documented in `deploy-branches`
- The body of every issue and pull request follows the canonical section vocabulary documented under `.claude/rules/enterprise-voice.md`; issue body style and required section ordering are further detailed in `.claude/rules/issue-writing.md`. Casual idioms, internet abbreviations, and emoji characters are not permitted in any artifact.

## Title style — Hybrid Convention

Every title shares the conventional-commit shape: `<type>(<scope>): <subject>` with the subject in imperative / verb-first form per `conventional-commits`. Strictness differs by artifact, but the shape never does.

| Artifact         | Enforcement                                | Rules                                                                                                       |
| ---------------- | ------------------------------------------ | ----------------------------------------------------------------------------------------------------------- |
| **Commit title** | Strict — commitlint runs on every commit   | type-enum, `scope-empty: never`, `subject-case: lower-case`, `subject-max-length: 72`                       |
| **PR title**     | Strict — squash-merge replays it as commit | Same as commit                                                                                              |
| **Issue title**  | Hybrid — same shape, relaxed length        | Starts with `<type>(<scope>): `; verb-first subject; no length cap but keep it scannable in the GitHub list |

### Good examples (issue, PR, commit)

- `feat(storefront): add public active services endpoint`
- `fix(auth): reject inactive tenant login`
- `ci(github): validate pr title issue references`
- `docs(api): document public booking service contract`
- `refactor(db): extract services repository`
- `feat(api): land core modules first milestone`

### Forbidden in any title (issue, PR, commit, or branch)

- **No `+` as shorthand.** Write `and` between two items or commas between three or more. Wrong: `Auth + Tenant + RBAC guards`. Right: `Auth, Tenant, and RBAC guards`.
- **No reference to personal-tooling or agent-configuration files in artifact titles.** These files are individual setup and not a team standard. Inline the rationale.
- **No user-story prose in titles.** "As a guest, I want…" belongs in the Issue Form body, not the title. The title is `feat(pricing): allow guests to view pricing without an account`; the user story sits in the body.
- **English only.** Thai is for chat, not artifacts.

### Mapping bug and incident issues into the shape

- Bug: `fix(<scope>): <symptom>` — example `fix(auth): /merchant/me returns 500 when token has no email claim`
- Incident: `fix(<area>): <what broke, where, since when>` — example `fix(api-prod): 502s on /public/stores/* since 14:00 UTC`. The `incident` label distinguishes the workflow.

### Title carries no issue or PR reference

The PR / commit title carries **no** `#N` reference at all. GitHub auto-appends `(#<this-PR>)` to the squash-merge commit subject, so any `(#N)` you put in the title produces a duplicate `(#N) (#<this-PR>)` on `dev`. Closures live exclusively in the PR body.

### Body closing-keyword form

GitHub's auto-close parser only matches `<keyword> <#N>` when they are **directly adjacent**. `Closes #1, #2, #3` closes only `#1` — every following `#N` after the comma is ignored and the corresponding issues stay open. Use one of the two supported forms:

**Per-line (recommended for multi-part PRs):**

```
Closes #1
Closes #2
Closes #3
```

**Repeated keyword on one line:**

```
Closes #1, closes #2, closes #3
```

Both forms are enforced by `.github/scripts/check-pr-title-references.sh`:

- Right: title `refactor(api): omit empty envelope keys` · body uses per-line `Closes #54` / `Closes #55` / ... · squash-merge subject becomes `refactor(api): omit empty envelope keys (#PR)`
- Right: title `fix(auth): reject inactive tenant login` · body `Closes #88` · squash-merge subject becomes `fix(auth): reject inactive tenant login (#PR)`
- Wrong: title `refactor(api): omit empty envelope keys (#54)` — squash-merge would emit `... (#54) (#PR)`
- Wrong: body `Closes #54, #55, #56` — GitHub closes only `#54`; `#55` and `#56` stay open

## Sub-issue tracking

A parent issue that lists sub-issues as a markdown checklist needs **manual sync** after each sub PR merges:

- GitHub's auto-close parser (`Closes #N`) closes the sub-issue on merge, but the parent's `- [ ]` lines are plain text — GitHub does not flip them to `- [x]` automatically.
- After each sub PR merges, the agent (or contributor) must fetch the parent body, tick the matching line, and push the body back:

  ```bash
  gh issue view <parent> --json body --jq .body > /tmp/parent.md
  # edit /tmp/parent.md: change `- [ ] Sub X — ...` to `- [x] Sub X — ...`
  gh issue edit <parent> --body-file /tmp/parent.md
  gh issue view <parent> --json body --jq .body | grep "Sub X"  # verify
  ```

- The post-merge probe documented under this rule owns the sync step for the agent flow. After a sub pull request merges, the agent (or the contributor running the manual workflow) fetches the parent body, ticks the matching line, and pushes the body back.
- An alternative is GitHub's native Sub-issues relationship (parent and child with auto progress), which auto-tracks without manual edits. The repository defaults to markdown checklists today; migration is a future decision.

## Milestones

Milestones group issues and PRs by deliverable goal — a coarser unit than a single PR but finer than the whole product. Use them when work spans multiple PRs and you want the GitHub milestone view to show progress.

- Source of truth is the GitHub milestones page, not any markdown checklist in the repo. A milestone is open until every issue and PR attached to it is closed.
- Create with `gh api repos/<owner>/<repo>/milestones -X POST -f title="<title>" -f description="<body>"`.
- Title format: `M<n> — <deliverable state>` (e.g. `M1 — Platform auth and user management`). The `M<n>` prefix gives ordering; the rest names the state the product reaches when the milestone closes.
- Attach during issue creation: `gh issue create --milestone "<title>" ...`.
- Attach during PR creation: `gh pr create --milestone "<title>" ...`.
- **Verify after attaching.** The `--milestone` flag has been observed to silently no-op on `gh issue create`. Always confirm with `gh issue view <N> --json milestone` and fix with `gh issue edit <N> --milestone "<title>"` if needed.
- When a PR closes issues, the PR's milestone should match the closed issues' milestone so the GitHub milestone view counts both.
- Do not pre-open every milestone in the roadmap. Open one milestone at a time, just before its first sub-issue is scheduled.

## Default flag block

Issue creation and pull request creation each carry default flags that the command-line invocation reproduces every time. Pass the flags directly to `gh`; no wrapper script intervenes.

**Issue creation:**

```bash
gh issue create \
  --title "<type>(<scope>): <verb-first subject>" \
  --body-file <path> \
  --label "<type-label>" \
  --label "<area:label>" \
  --label "<priority:label>" \
  --milestone "<title-if-applicable>" \
  --assignee joetakara \
  --assignee nextfridaydeveloper
```

The `--assignee` pair is required on every issue. The Issue Forms under `.github/ISSUE_TEMPLATE/` pre-fill `assignees`, `labels`, and `title` for UI-opened issues; the command-line path must add the equivalent flags explicitly because `gh issue create --template <name>` loads only the body content, not the frontmatter metadata. Unassigned issues hide from the My Issues view and weaken the audit trail.

**Pull request creation:**

```bash
gh pr create \
  --base dev \
  --head <branch> \
  --title "<type>(<scope>): <verb-first subject>" \
  --body-file <path> \
  --label "<type-label>" \
  --label "<area:label>" \
  --milestone "<title-if-applicable>" \
  --reviewer nextfridaydeveloper
```

The `--reviewer nextfridaydeveloper` flag is required on every pull request. `joetakara` cannot self-review and is not added as a reviewer; the assignee, the author, and the CODEOWNERS file together establish the ownership trail. The path-based labeler attaches the area label automatically, but the explicit `--label` keeps the command self-contained when the labeler is degraded.

## Exceptions

- None — applies to every issue, PR, branch, and commit
