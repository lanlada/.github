#!/usr/bin/env bash
set -euo pipefail

base="${1:-${BASE:-}}"
head="${2:-${HEAD:-}}"

if [ -z "$base" ] || [ -z "$head" ]; then
  echo "Usage: $0 <base-branch> <head-branch>" >&2
  exit 2
fi

ok=0
case "$base" in
  dev)
    case "$head" in
      dev|uat|main) ok=0 ;;
      *) ok=1 ;;
    esac
    ;;
  uat)
    if [ "$head" = "dev" ]; then
      ok=1
    fi
    ;;
  main)
    case "$head" in
      uat|hotfix/*) ok=1 ;;
      *) ok=0 ;;
    esac
    ;;
  *)
    echo "::error::Cannot target base '$base' — PRs may target only dev, uat, or main." >&2
    exit 1
    ;;
esac

if [ "$ok" != "1" ]; then
  echo "::error::Invalid PR pairing: '$head' -> '$base'." >&2
  echo "::error::Allowed pairings:" >&2
  echo "::error::  any non-deploy branch -> dev" >&2
  echo "::error::  dev                   -> uat" >&2
  echo "::error::  uat | hotfix/*        -> main" >&2
  exit 1
fi

echo "PR pairing OK: $head -> $base"
