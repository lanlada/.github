#!/usr/bin/env bash
set -euo pipefail

head="${HEAD:-${1:-}}"
repo="${GITHUB_REPOSITORY:-${2:-}}"

if [ -z "$head" ]; then
  echo "::error::HEAD env var or first arg required (the PR's head_ref)" >&2
  exit 2
fi

if [[ ! "$head" =~ ^[0-9]+- ]]; then
  echo "Branch '$head' is not a numbered branch (e.g. hotfix/* or release/*) — issue-exists check skipped."
  exit 0
fi

issue_number="${head%%-*}"

if [ -z "${GH_TOKEN:-}" ] && [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "::error::GH_TOKEN or GITHUB_TOKEN env var required to query issue state" >&2
  exit 2
fi

if [ -z "$repo" ]; then
  echo "::error::GITHUB_REPOSITORY env var or second arg required" >&2
  exit 2
fi

api_response=$(gh api "repos/${repo}/issues/${issue_number}" 2>&1) || api_status=$?
api_status=${api_status:-0}

if [ "$api_status" -ne 0 ]; then
  if printf '%s' "$api_response" | grep -q "Not Found"; then
    cat >&2 <<EOF
::error::Branch '$head' claims to track issue #${issue_number}, but no such issue exists on the repo.
::error::Either rename the branch to point at a real open issue (git branch -m <new>), or open issue #${issue_number} first.
EOF
    exit 1
  fi
  cat >&2 <<EOF
::error::Failed to query issue #${issue_number}: ${api_response}
EOF
  exit 1
fi

state=$(printf '%s' "$api_response" | jq -r '.state // empty')
pull_request_url=$(printf '%s' "$api_response" | jq -r '.pull_request.url // empty')

if [ -n "$pull_request_url" ]; then
  cat >&2 <<EOF
::error::Branch '$head' points at #${issue_number}, but #${issue_number} is a PR, not an issue.
::error::Branches must reference issues. Open a tracking issue and rename the branch to its number.
EOF
  exit 1
fi

if [ "$state" != "open" ]; then
  cat >&2 <<EOF
::error::Branch '$head' points at issue #${issue_number}, but #${issue_number} is currently '$state'.
::error::Reopen the issue before merging this PR, or rename the branch to point at an open issue.
EOF
  exit 1
fi

echo "Issue #${issue_number} exists and is open on ${repo}."
