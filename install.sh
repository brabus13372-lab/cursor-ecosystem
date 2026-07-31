#!/usr/bin/env bash
# Install Cursor Ecosystem to ~/.cursor
# Usage:
#   ./install.sh              # install (overwrite)
#   ./install.sh --dry-run    # plan only — no writes
#   ./install.sh --backup     # snapshot existing targets before overwrite
#   ./install.sh --dry-run --backup
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DST="${HOME}/.cursor"
DIRS=(skills commands agents hooks memory)
DRY_RUN=0
DO_BACKUP=0

for arg in "$@"; do
  case "$arg" in
    --dry-run|-DryRun) DRY_RUN=1 ;;
    --backup|-Backup) DO_BACKUP=1 ;;
    -h|--help)
      echo "Usage: $0 [--dry-run] [--backup]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--dry-run] [--backup]" >&2
      exit 1
      ;;
  esac
done

file_count() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo 0
    return
  fi
  find "$path" -type f 2>/dev/null | wc -l | tr -d ' '
}

newest_mtime() {
  local path="$1"
  if [[ ! -e "$path" ]]; then
    echo ""
    return
  fi
  # GNU find
  if find "$path" -type f -printf '%T@\n' -quit 2>/dev/null | grep -q .; then
    find "$path" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1
    return
  fi
  # BSD/macOS
  find "$path" -type f -exec stat -f %m {} \; 2>/dev/null | sort -n | tail -1
}

echo "Source: $REPO_ROOT"
echo "Target: $DST"
[[ "$DRY_RUN" -eq 1 ]] && echo "Mode:   DRY-RUN (no writes)"
[[ "$DO_BACKUP" -eq 1 ]] && echo "Mode:   BACKUP before overwrite"
echo ""

DRIFT=0
for dir in "${DIRS[@]}"; do
  src="$REPO_ROOT/$dir"
  target="$DST/$dir"
  [[ -d "$src" ]] || continue
  src_n="$(file_count "$src")"
  dst_n="$(file_count "$target")"
  src_m="$(newest_mtime "$src")"
  dst_m="$(newest_mtime "$target")"
  status="ok"
  if [[ -d "$target" ]]; then
    if [[ "$src_n" != "$dst_n" ]] || { [[ -n "$dst_m" && -n "$src_m" ]] && awk -v d="$dst_m" -v s="$src_m" 'BEGIN{exit !(d>s)}'; }; then
      status="DIFFERS"
      DRIFT=1
    fi
  else
    status="missing → will create"
  fi
  printf "  %-10s repo=%4s files  dest=%4s files  %s\n" "$dir" "$src_n" "$dst_n" "$status"
done

if [[ -f "$REPO_ROOT/hooks.json" ]]; then
  h_status="ok"
  if [[ -f "$DST/hooks.json" ]]; then
    if command -v sha256sum >/dev/null 2>&1; then
      src_hash="$(sha256sum "$REPO_ROOT/hooks.json" | awk '{print $1}')"
      dst_hash="$(sha256sum "$DST/hooks.json" | awk '{print $1}')"
    else
      src_hash="$(shasum -a 256 "$REPO_ROOT/hooks.json" | awk '{print $1}')"
      dst_hash="$(shasum -a 256 "$DST/hooks.json" | awk '{print $1}')"
    fi
    if [[ "$src_hash" != "$dst_hash" ]]; then
      h_status="DIFFERS"
      DRIFT=1
    fi
  else
    h_status="missing → will create"
  fi
  printf "  %-10s %s\n" "hooks.json" "$h_status"
fi

if [[ "$DRIFT" -eq 1 ]]; then
  echo ""
  echo "WARNING: destination differs from repo (counts and/or newer dest mtimes / hooks.json hash)."
  echo "         Local-only edits in ~/.cursor may be overwritten. Prefer --backup."
fi

BACKUP_ROOT=""
if [[ "$DO_BACKUP" -eq 1 ]]; then
  stamp="$(date +%Y%m%d-%H%M%S)"
  BACKUP_ROOT="${HOME}/.cursor-backup-${stamp}"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo ""
    echo "Would backup existing targets → $BACKUP_ROOT"
  else
    mkdir -p "$BACKUP_ROOT"
    for dir in "${DIRS[@]}"; do
      target="$DST/$dir"
      if [[ -d "$target" ]]; then
        cp -R "$target" "$BACKUP_ROOT/$dir"
        echo "BACKUP $dir"
      fi
    done
    if [[ -f "$DST/hooks.json" ]]; then
      cp "$DST/hooks.json" "$BACKUP_ROOT/hooks.json"
      echo "BACKUP hooks.json"
    fi
    echo "Backup saved: $BACKUP_ROOT"
  fi
fi

echo ""
for dir in "${DIRS[@]}"; do
  src="$REPO_ROOT/$dir"
  [[ -d "$src" ]] || continue
  target="$DST/$dir"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "PLAN copy $dir → $target"
  else
    mkdir -p "$target"
    cp -R "$src/." "$target/"
    echo "OK $dir"
  fi
done

if [[ -f "$REPO_ROOT/hooks.json" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "PLAN copy hooks.json → $DST/hooks.json"
  else
    cp "$REPO_ROOT/hooks.json" "$DST/hooks.json"
    echo "OK hooks.json"
  fi
fi

echo ""
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Dry-run complete — nothing written to $DST"
  exit 0
fi
echo "Installed to $DST"
echo "Restart Cursor or open a new Agent chat."
