# Godot Starter — Godot 4.7 project

Base project with headless tooling. There is no game yet: `scenes/main.tscn` shows a score label and
`scripts/game/game_state.gd` is a placeholder rules class. Replace both, keep the structure.
Godot version is pinned in `.godot-version`; the engine lives in `.godot-bin/` (`make install-godot`).

## Layout

- `scripts/game/` — pure rules, no nodes (all `RefCounted`, fully unit-tested). Example: `game_state.gd`.
- `scripts/main.gd` — wires rules to the HUD and forwards input. `scenes/main.tscn` — the entry scene.
- `tests/` — headless runner (`run_tests.gd`), base class (`test_suite.gd`), suites in `tests/unit/test_*.gd`.
- `tools/` — `godot.sh` (finds the pinned binary), `install-godot.sh`, `smoke.sh`, `capture.gd` (screenshots).
- `.claude/skills/` — `godot-dev-loop`, `gdscript`, `godot-scene-files`, `godot-tests`.

## Commands

Always use `make` targets — they go through `tools/godot.sh`, which finds the pinned binary.

- `make check` — lint + format check + tests + smoke. **Run before calling any change done.**
- `make test` / `make test FILTER=test_game_state` — unit tests.
- `make smoke` — boots the main scene headless and fails on any engine/script error.
- `make screenshot ARGS="--frames=10"` — opens a window briefly and saves `build/screenshots/capture.png`.
  Read the PNG to check visuals after any rendering change.
- `make format` — auto-format GDScript (gdformat, via `uvx`).
- `make import` — rebuild the class cache; needed after adding/renaming a `class_name` or asset.
- `make api-docs` — dump the engine API reference for the pinned version to `.godot-bin/api-docs/`.
- `make run` — launch the game. `make editor` — open the Godot editor.

## Rules

- Godot **4.x** GDScript only. Never write Godot 3 syntax — see the `gdscript` skill.
- Static typing everywhere (`var x: int`, `-> void`, `:=`). The project warns on untyped declarations.
- Game rules go in `scripts/game/` with tests; nodes only draw and forward input.
- When unsure whether an API exists in this engine version, grep `.godot-bin/api-docs/` rather than guessing.
- Hand-editing `.tscn`/`.tres` is fine but follow the `godot-scene-files` skill. Never invent `uid://` values.
- Commit `*.gd.uid` files alongside their scripts. Never commit `.godot/`, `.godot-bin/`, or `build/`.

## Starting a new game from this template

1. Rename: `config/name` in `project.godot`, `APP_NAME` in the `Makefile`, export paths and
   `application/bundle_identifier` in `export_presets.cfg`, this file's title, and `README.md`.
2. Replace `scripts/game/game_state.gd` and its test with your rules; replace `scenes/main.tscn` + `scripts/main.gd`.
3. Add input actions to `project.godot` `[input]` (see `godot-scene-files`), then `make check`.
