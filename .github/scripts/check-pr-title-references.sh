#!/usr/bin/env bash
set -euo pipefail

title="${PR_TITLE:-}"
body="${PR_BODY:-}"

if [ -z "$title" ]; then
  echo "::error::PR_TITLE env var is required" >&2
  exit 2
fi

title_refs=$(printf '%s' "$title" | grep -oE '#[0-9]+' || true)

if [ -n "$title_refs" ]; then
  cat >&2 <<EOF
::error::PR title must not contain any '#N' issue or PR reference.
::error::Title: $title
::error::Refs in title: $(echo "$title_refs" | tr '\n' ' ')
::error::GitHub appends '(#<this-PR>)' to the squash-merge commit subject automatically.
::error::Adding '(#N)' in the title produces a duplicate '(#N) (#<this-PR>)' on dev.
::error::Closures belong in the body as one 'Closes #N' per line; see the body check below.
EOF
  exit 1
fi

malformed=$(printf '%s\n' "$body" \
  | grep -iE '\b(close[sd]?|fix(es|ed)?|resolve[sd]?)[[:space:]]+#[0-9]+[[:space:]]*,[[:space:]]*#[0-9]+' \
  || true)

if [ -n "$malformed" ]; then
  cat >&2 <<EOF
::error::PR body uses a closing keyword followed by a comma-separated '#N' list. GitHub's auto-close parser only matches '<keyword> <#N>' when they are directly adjacent, so only the first '#N' actually closes; the rest stay open.
::error::Offending line(s):
$(printf '%s\n' "$malformed" | sed 's/^/::error::  /')
::error::Use one 'Closes #N' per line:
::error::  Closes #1
::error::  Closes #2
::error::  Closes #3
::error::Or repeat the keyword before every '#N':
::error::  Closes #1, closes #2, closes #3
EOF
  exit 1
fi

closes_issues=$(printf '%s\n' "$body" \
  | grep -oiE '\b(close[sd]?|fix(es|ed)?|resolve[sd]?)[[:space:]]+#[0-9]+' \
  | grep -oE '#[0-9]+' \
  | sort -u \
  || true)

if [ -z "$closes_issues" ]; then
  cat >&2 <<EOF
::error::PR body has no 'Closes / Fixes / Resolves #N' keyword. Every PR must reference at least one issue so the audit trail issue -> branch -> PR -> commit is unbroken.
::error::Add one 'Closes #N' per line in the body for every issue this PR resolves.
::error::Example body:
::error::  Closes #42
::error::  Closes #43
::error::If the work genuinely has no tracking issue, open one first and reference it. The 'enterprise issue pattern' rule on this repo requires it.
EOF
  exit 1
fi

echo "PR body closes: $(echo "$closes_issues" | tr '\n' ' '). Title carries no refs; GitHub appends '(#<PR>)' on squash-merge."
