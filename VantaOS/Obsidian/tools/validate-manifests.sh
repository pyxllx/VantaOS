#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

for file in "$ROOT"/profiles/*/*.list; do
  [[ -f "$file" ]] || continue
  dupes="$(sed 's/#.*//' "$file" | awk 'NF {print $1}' | sort | uniq -d)"
  if [[ -n "$dupes" ]]; then
    echo "Duplicate entries in $file:"
    echo "$dupes"
    status=1
  fi
done

exit "$status"
