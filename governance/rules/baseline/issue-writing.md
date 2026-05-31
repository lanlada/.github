---
description: Issue bodies follow the canonical section vocabulary and use formal declarative voice
---

# Issue Writing

Issue bodies follow the canonical section vocabulary documented in `.claude/rules/enterprise-voice.md`. Templates in `.github/ISSUE_TEMPLATE/` enforce the field order; this rule covers the writing style inside the fields and the responsibilities each section carries.

## Prohibited

- Leading with a code snippet, a file path, a line count, or a framework name.
- Using jargon without defining the term on first use (for example, `progressive disclosure`, `frontmatter`, `idempotency`).
- Writing Acceptance Criteria as shell commands only. Non-engineering reviewers must be able to verify the conditions.
- Omitting the `Summary` section on the assumption that later sections cover the same ground.
- Applying priority labels without a one-line rationale.
- Naming "the team" as the subject of an action. State the role (`Engineering`, `Product`, `Support`) so the reader knows who acts.
- Treating an issue body as a private engineering notebook. Every issue is a customer-visible artifact.

## Required

- Lead with the `Summary` section as defined in `enterprise-voice` (one short paragraph, typically one or two sentences). Plain language; a product reader should understand the work at a glance.
- Use customer or business language in `Background` and `Customer Impact`. Phrases such as "lost bookings" or "blocked signup" are preferred over "ENOENT on disk".
- Use Given / When / Then in `Acceptance Criteria`. Include a Verification Procedure subsection with the exact shell commands and the expected output.
- Name stakeholders explicitly. Use role labels such as `Affected tenants`, `Engineering reviewer`, `Quality reviewer`, `Product owner`. The label `team` without qualification is insufficient.
- Select a T-shirt size in `Estimate` so the product owner can sequence work.
- Write `Definition of Done` as a measurable checklist (tests added, documentation updated, deployment confirmed, auto-close verified).
- Reference related issues with `#N`. Reference external documents with the full URL.
- Use English in every field. Conversation may switch languages; the artifact remains English.

## Reading Order for Non-Engineering Readers

1. `Summary` answers what the work is.
2. `Background` answers why the work exists now.
3. `Stakeholders` answers who acts.
4. `Definition of Done` answers when the work concludes.
5. The remaining sections are reference material for the engineering reviewer.

If a reader must scroll past `Background` to learn what the issue is, the `Summary` failed its purpose. Revise the `Summary`, not the reader's path.

## Exceptions

- Production incident issues lead with `Severity`, `Environment`, `Summary`, and `Blast Radius`. The incident format is its own enterprise pattern; the canonical vocabulary still applies, but `Summary` carries the one-line description of what broke and `Blast Radius` carries the scope at first observation.
