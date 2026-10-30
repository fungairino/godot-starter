#!/usr/bin/env bash
# Runs Godot, resolving the binary from $GODOT, then .godot-bin/, then PATH.
# Usage: tools/godot.sh [godot args...]    tools/godot.sh --print-path
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

resolve() {
  if [[ -n "${GODOT:-}" ]]; then echo "$GODOT"; return; fi
  local candidates=(
    "$ROOT/.godot-bin/Godot.app/Contents/MacOS/Godot"
    "$ROOT"/.godot-bin/Godot_v*_linux.x86_64
  )
  for c in "${candidates[@]}"; do
    if [[ -x "$c" ]]; then echo "$c"; return; fi
  done
  for name in godot godot4; do
    if command -v "$name" >/dev/null; then command -v "$name"; return; fi
  done
  return 1
}

if ! BIN="$(resolve)"; then
  echo "Godot not found. Run 'make install-godot' or set GODOT=/path/to/godot." >&2
  exit 127
fi

if [[ "${1:-}" == "--print-path" ]]; then
  echo "$BIN"
  exit 0
fi

exec "$BIN" --path "$ROOT" "$@"
