#!/usr/bin/env bash
# Downloads the Godot version pinned in .godot-version into .godot-bin/ (project-local, no system install).
# Pass --templates to also install the matching export templates.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT/.godot-version")"
BIN_DIR="$ROOT/.godot-bin"
BASE_URL="https://github.com/godotengine/godot/releases/download/$VERSION"

case "$(uname -s)" in
  Darwin)
    ARCHIVE="Godot_v${VERSION}_macos.universal.zip"
    TEMPLATES_DIR="$HOME/Library/Application Support/Godot/export_templates/${VERSION/-/.}"
    ;;
  Linux)
    ARCHIVE="Godot_v${VERSION}_linux.x86_64.zip"
    TEMPLATES_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/godot/export_templates/${VERSION/-/.}"
    ;;
  *)
    echo "Unsupported OS: $(uname -s). Install Godot $VERSION manually and set GODOT=/path/to/godot." >&2
    exit 1
    ;;
esac

if [[ -x "$("$ROOT/tools/godot.sh" --print-path 2>/dev/null || true)" ]]; then
  echo "Godot $VERSION already installed in $BIN_DIR"
else
  mkdir -p "$BIN_DIR"
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  echo "Downloading $ARCHIVE..."
  curl -fL --progress-bar -o "$TMP/godot.zip" "$BASE_URL/$ARCHIVE"
  unzip -q -o "$TMP/godot.zip" -d "$BIN_DIR"
  echo "Installed Godot $VERSION to $BIN_DIR"
fi

if [[ "${1:-}" == "--templates" ]]; then
  if [[ -f "$TEMPLATES_DIR/version.txt" ]]; then
    echo "Export templates already installed in $TEMPLATES_DIR"
    exit 0
  fi
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  echo "Downloading export templates (large)..."
  curl -fL --progress-bar -o "$TMP/templates.tpz" "$BASE_URL/Godot_v${VERSION}_export_templates.tpz"
  unzip -q -o "$TMP/templates.tpz" -d "$TMP"
  mkdir -p "$TEMPLATES_DIR"
  cp -R "$TMP/templates/." "$TEMPLATES_DIR/"
  echo "Installed export templates to $TEMPLATES_DIR"
fi
