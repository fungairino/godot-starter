#!/usr/bin/env bash
# Boots the main scene headless for a few seconds and fails on any engine/script error.
# Usage: tools/smoke.sh [frames] [scene]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRAMES="${1:-300}"
SCENE="${2:-}"

OUTPUT="$("$ROOT/tools/godot.sh" --headless --quit-after "$FRAMES" ${SCENE:+"$SCENE"} 2>&1)"
echo "$OUTPUT"
if grep -qE "SCRIPT ERROR|^ERROR:|Parse Error|Failed to load" <<<"$OUTPUT"; then
  echo "Smoke test failed: errors in output above." >&2
  exit 1
fi
echo "Smoke test passed ($FRAMES frames)."
