#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: sync-labels.sh <owner/repo> <nextjs|nestjs> [--dry-run]" >&2
  exit 2
}

[ $# -ge 2 ] || usage
REPO="$1"
STACK="$2"
shift 2
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

case "$STACK" in
  nextjs | nestjs) ;;
  *)
    echo "unknown stack: $STACK" >&2
    usage
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LABELS_DIR="$SCRIPT_DIR/../labels"
BASELINE="$LABELS_DIR/baseline.yml"
OVERLAY="$LABELS_DIR/overlay-$STACK.yml"

for f in "$BASELINE" "$OVERLAY"; do
  [ -f "$f" ] || {
    echo "missing label file: $f" >&2
    exit 1
  }
done

DESIRED_JSON="$(python3 - "$BASELINE" "$OVERLAY" <<'PY'
import sys, json, yaml

items, seen = [], set()
for path in sys.argv[1:]:
    with open(path) as fh:
        data = yaml.safe_load(fh) or {}
    for entry in data.get("labels", []):
        name = entry["name"]
        if name in seen:
            raise SystemExit(f"duplicate label across files: {name}")
        seen.add(name)
        items.append({
            "name": name,
            "color": str(entry["color"]),
            "description": entry.get("description", ""),
        })
json.dump(items, sys.stdout)
PY
)"

DESIRED_NAMES="$(printf '%s' "$DESIRED_JSON" | jq -r '.[].name')"
COUNT="$(printf '%s' "$DESIRED_JSON" | jq 'length')"

suffix=""
[ "$DRY_RUN" -eq 1 ] && suffix=" [dry-run]"
echo "==> syncing $COUNT labels to $REPO (stack: $STACK)$suffix"

printf '%s' "$DESIRED_JSON" | jq -c '.[]' | while IFS= read -r row; do
  name="$(jq -r '.name' <<<"$row")"
  color="$(jq -r '.color' <<<"$row")"
  desc="$(jq -r '.description' <<<"$row")"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "  upsert: $name ($color)"
  else
    gh label create "$name" -R "$REPO" --color "$color" --description "$desc" --force >/dev/null
    echo "  upsert: $name"
  fi
done

CURRENT="$(gh label list -R "$REPO" --limit 200 --json name --jq '.[].name')"
while IFS= read -r cur; do
  [ -z "$cur" ] && continue
  if ! printf '%s\n' "$DESIRED_NAMES" | grep -Fxq "$cur"; then
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "  prune:  $cur"
    else
      gh label delete "$cur" -R "$REPO" --yes >/dev/null && echo "  prune:  $cur"
    fi
  fi
done <<<"$CURRENT"

echo "==> done"
