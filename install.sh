#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DST="$HOME/.cursor"

for dir in skills commands agents hooks memory; do
  if [[ -d "$REPO_ROOT/$dir" ]]; then
    mkdir -p "$DST/$dir"
    cp -R "$REPO_ROOT/$dir/." "$DST/$dir/"
    echo "OK $dir"
  fi
done

if [[ -f "$REPO_ROOT/hooks.json" ]]; then
  cp "$REPO_ROOT/hooks.json" "$DST/hooks.json"
  echo "OK hooks.json"
fi

echo ""
echo "Installed to $DST"
echo "Restart Cursor or open a new Agent chat."
