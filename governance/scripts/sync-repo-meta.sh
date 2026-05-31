#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: sync-repo-meta.sh [--repo <name>] [--dry-run]" >&2
  exit 2
}

ONLY=""
DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      ONLY="${2:-}"
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META="$SCRIPT_DIR/../repo-meta.yml"
OWNER="lanlada"
[ -f "$META" ] || {
  echo "missing metadata file: $META" >&2
  exit 1
}

ROWS="$(python3 - "$META" <<'PY'
import sys, yaml

data = yaml.safe_load(open(sys.argv[1])) or {}
for r in data.get("repos", []):
    print("\t".join([r["name"], r.get("description", ""), ",".join(r.get("topics", []))]))
PY
)"

suffix=""
[ "$DRY_RUN" -eq 1 ] && suffix=" [dry-run]"

printf '%s\n' "$ROWS" | while IFS=$'\t' read -r name desc topics; do
  [ -z "$name" ] && continue
  if [ -n "$ONLY" ] && [ "$name" != "$ONLY" ]; then
    continue
  fi
  echo "==> $OWNER/$name$suffix"
  echo "    description: $desc"
  echo "    topics: $topics"
  if [ "$DRY_RUN" -eq 0 ]; then
    gh repo edit "$OWNER/$name" --description "$desc" >/dev/null
    topic_args=()
    IFS=',' read -ra topic_list <<<"$topics"
    for t in "${topic_list[@]}"; do
      topic_args+=(-f "names[]=$t")
    done
    gh api -X PUT "repos/$OWNER/$name/topics" "${topic_args[@]}" >/dev/null
    echo "    applied"
  fi
done

echo "==> done"
