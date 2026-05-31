---
description: Formal declarative voice standard for customer-facing artifacts, defining the canonical section vocabulary, prohibited idioms, and emoji policy
---

# Enterprise Voice

All written artifacts produced for or visible to the customer use a formal, declarative voice. The artifact set covered by this rule includes issue and pull request bodies, commit titles, repository documentation in the root of the repository (`CLAUDE.md`, `README.md`), template files under `.github/`, and rule files under `.claude/rules/`. Vendored third-party skill content under `.agents/skills/` is outside the scope of this rule. Structural requirements (templates, labels, milestones, branch naming) are governed by `.claude/rules/github-templates.md`.

Casual phrasing, internet idioms, and emoji characters are not permitted. The standard applies regardless of who authors the artifact (maintainer, contributor, or agent).

## Section Vocabulary

The following section names are the canonical set. Issue templates, pull request templates, skill outputs, and rule cross-references use these names verbatim. New sections require an entry in this rule before use.

| Section             | Purpose                                                                                                           |
| ------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Summary             | One short paragraph stating what the work is and what end state it produces. No "TL;DR" label, no question marks. |
| Background          | Prior state, relevant history, technical or business context that informs the work.                               |
| Objective           | The outcome the work delivers, stated as a single declarative sentence.                                           |
| Scope               | The work the artifact covers, grouped under bold subsection labels where useful.                                  |
| Exclusions          | Work the artifact deliberately omits. Replaces "Out of scope".                                                    |
| Acceptance Criteria | Verifiable conditions in `Given / When / Then` form.                                                              |
| Definition of Done  | A checklist that converts the artifact from in-progress to complete.                                              |
| Dependencies        | External or internal work that must complete before the artifact begins.                                          |
| Stakeholders        | Named roles or individuals involved in the artifact.                                                              |
| Estimate            | T-shirt size with the corresponding effort window.                                                                |
| References          | Links and document identifiers used during the work.                                                              |
| Risks               | Identified risks with mitigation or ownership notes.                                                              |
| Open Questions      | Optional. Lists items that are not yet resolved and the decision owner.                                           |

Bug reports add `Severity`, `Environment`, `Customer Impact`, `Reproduction Steps`, `Expected Behavior`, `Actual Behavior`, `Workaround`, and `Blast Radius` between Background and References. Feature requests add `Target User`, `Business Context`, `Success Metrics`, `Problem Statement`, `Proposed Solution`, and `Alternatives Considered`. Incident reports add `Severity`, `Environment`, `Blast Radius`, `Timeline`, `Mitigation Applied`, `Suspected Root Cause`, `Architecture Invariants Affected`, and `Post-Mortem Owner`.

## Prohibited Idioms and Phrases

The following terms and phrases must not appear in any artifact covered by this rule.

- `TL;DR`, `tl;dr`, `Summary (TL;DR)`
- `Why now`, `Cost of delay`
- `lock down`, `lock it down`
- `ship`, `ship it` (use `deliver`, `release`, or `merge`)
- `kicks in`, `kick off` (use `applies`, `activates`, `begins`)
- `rolls out`, `roll out` (use `deploys`, `is released`)
- `gonna`, `wanna`, `let's`
- `we'll`, `we've`, `we should`, `you'll`, `you should`, `we need to`
- `make sure` (use `ensure`)
- `figure out` (use `determine`)
- `gotcha`, `wow`, `easy`, `simple`, `obvious`
- `How to test`, `How to apply` (use `Verification Procedure`, `Application`)

Vendored third-party skill files retain their original phrasing because rewriting them would break upstream synchronization. The vendored content is not produced by the project and is not in scope.

## Prohibited Path References

The artifacts covered by this rule must stand alone. A citation to a file that only the agent or the maintainer can read defeats the purpose of a customer-facing artifact. The following path patterns must not appear in any artifact covered by this rule. Inline the rationale rather than citing the file.

- `docs/superpowers/**` — superpowers skill working artifacts; off-repository by override
- `.superpowers/**` — alternative location for superpowers skill working artifacts
- `~/.claude/**` — agent memory, plugin caches, and project-scoped working files outside the repository
- `.claude/**` — repository-local agent configuration (rules, hooks, scripts, settings)
- `CLAUDE.md` — the agent instruction entry point
- `.agents/skills/**` — agent skill definitions, both vendored and project-authored

A rule file under `.claude/rules/` may reference these paths because the rule file itself is an agent artifact and not a customer-facing artifact. The exception preserves the existing cross-references used by `.claude/rules/lint-rules-locked.md`, `.claude/rules/no-code-comments.md`, and this rule.

## Emoji Policy

The artifacts covered by this rule contain no emoji characters and no decorative unicode symbols. Status indicators are expressed as text: `(complete)`, `(pending)`, `(blocked)`, `(deferred)`. Bullet lists do not begin with checkmarks or arrows.

The scan procedure for emoji and prohibited idioms in committed artifacts is the helper script:

```bash
bash .claude/scripts/voice-scan.sh
```

The script runs the emoji grep and the prohibited-idiom grep across the project-owned artifact set (`.github/`, `.claude/`, and the root markdown documents). Vendored skill content under `.agents/skills/` and memory under `/memory/` are excluded. Exit zero with `voice scan: clean` indicates a clean artifact set; exit one prints every finding by file and line.

## Voice and Tone

Declarative sentences. No rhetorical questions in artifact bodies. Active voice where the subject of the sentence is the system or the engineer; passive voice where the subject is the action itself. No first-person pronouns. Second-person pronouns are acceptable only in procedural instructions that name the engineer as the actor.

Bullet lists are substantive. Each bullet contains either a fact, a step, or a criterion. Empty rhetorical bullets are not permitted.

Capitalisation follows standard English. Project and vendor nouns (`GitHub`, `TypeScript`, `Node.js`) are capitalised as the vendor capitalises them. Acronyms are uppercase (`API`, `URL`, `JWT`, `CORS`).

## Compliance Verification

Compliance is verified by two passes:

1. The maintainer runs the prohibited-string search and the emoji scan across the artifact set listed above. The search returns no matches.
2. Every issue body and pull request body that touches the project follows the canonical section vocabulary. Any artifact that deviates is treated as a defect and is corrected before merge.

## Exceptions

- Chat exchanges between the maintainer and the agent are not subject to this rule. The standard applies to artifacts that other parties read; chat is informal by design.
- Vendored skill content under `.agents/skills/` that originated from a tracked upstream source is outside the scope. The project does not modify vendored content; if the vendored phrasing becomes a problem, the resolution is to drop the dependency or fork it, not to rewrite the file in place.
- Commit message bodies authored before this rule landed are not retroactively rewritten. The history is preserved as-is.
