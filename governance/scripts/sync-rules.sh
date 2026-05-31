#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: sync-rules.sh --repo <path> --stack <nextjs|nestjs> [--dry-run]" >&2
  exit 2
}

REPO=""
STACK=""
DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      REPO="${2:-}"
      shift 2
      ;;
    --stack)
      STACK="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage
      ;;
  esac
done

[ -n "$REPO" ] && [ -n "$STACK" ] || usage
case "$STACK" in
  nextjs | nestjs) ;;
  *)
    echo "unknown stack: $STACK" >&2
    usage
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULES_DIR="$SCRIPT_DIR/../rules"
BASELINE="$RULES_DIR/baseline"
OVERLAY="$RULES_DIR/overlays/$STACK"
TARGET="$REPO/.claude/rules"

for d in "$BASELINE" "$OVERLAY"; do
  [ -d "$d" ] || {
    echo "missing source directory: $d" >&2
    exit 1
  }
done
[ -d "$REPO/.claude" ] || {
  echo "target repository has no .claude directory: $REPO" >&2
  exit 1
}

DESIRED="$(for f in "$BASELINE"/*.md "$OVERLAY"/*.md; do basename "$f"; done | sort -u)"

suffix=""
[ "$DRY_RUN" -eq 1 ] && suffix=" [dry-run]"
echo "==> syncing $(printf '%s\n' "$DESIRED" | wc -l | tr -d ' ') rules to $TARGET (stack: $STACK)$suffix"
mkdir -p "$TARGET"

for src in "$BASELINE"/*.md "$OVERLAY"/*.md; do
  name="$(basename "$src")"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  copy:  $name"
  else
    cp "$src" "$TARGET/$name"
    echo "  copy:  $name"
  fi
done

for existing in "$TARGET"/*.md; do
  [ -e "$existing" ] || continue
  name="$(basename "$existing")"
  if ! printf '%s\n' "$DESIRED" | grep -Fxq "$name"; then
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "  prune: $name"
    else
      rm "$existing"
      echo "  prune: $name"
    fi
  fi
done

echo "==> done"
