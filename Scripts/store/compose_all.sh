#!/usr/bin/env bash
# Compose 2560x1600 marketing screenshots from raw captures, per Scripts/store/captions.txt.
# Output: Store/screenshots/<locale>/01..04_*.png (numeric prefix = display order).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CAPTIONS="$ROOT/Scripts/store/captions.txt"
COMPOSE="$ROOT/Scripts/store/compose"

[[ -x "$COMPOSE" ]] || swiftc -O "$ROOT/Scripts/store/compose.swift" -o "$COMPOSE"

while IFS='|' read -r LOCALE SHOT HEADLINE SUBTITLE; do
  [[ -z "${LOCALE}" || "${LOCALE}" == \#* ]] && continue
  IN="$ROOT/Store/screenshots/raw/${LOCALE}/${SHOT}.png"
  [[ -f "$IN" ]] || { echo "skip ${LOCALE}/${SHOT} (no raw capture)"; continue; }
  OUTDIR="$ROOT/Store/screenshots/${LOCALE}"
  mkdir -p "$OUTDIR"
  case "$SHOT" in
    onboarding) N=01 ;;
    general)    N=02 ;;
    durations)  N=03 ;;
    battery)    N=04 ;;
    *) echo "unknown shot: $SHOT"; continue ;;
  esac
  "$COMPOSE" "$IN" "$HEADLINE" "$SUBTITLE" "$OUTDIR/${N}_${SHOT}.png"
done < "$CAPTIONS"

echo "composed into $ROOT/Store/screenshots/"
