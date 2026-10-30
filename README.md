# Godot Starter

A base [Godot 4](https://godotengine.org/) project with a headless, command-line development loop:
pinned engine version, GDScript lint and format, an in-repo test runner, a smoke test, screenshot
capture, export presets, and GitHub Actions CI. Designed to be driven by humans and coding agents alike.

The placeholder "game" is a score label that goes up when you press Space. Replace it.

## Quick start

Requires `make`, `curl`, `unzip`, and [uv](https://docs.astral.sh/uv/) (for the GDScript linter/formatter).

```sh
make install-godot   # downloads the Godot version in .godot-version into .godot-bin/
make run             # run the main scene
make editor          # open in the Godot editor
make check           # lint + format check + tests + headless smoke test
make screenshot      # save build/screenshots/capture.png
```

Already have Godot installed? Set `GODOT=/path/to/godot` instead of running `make install-godot`.
Run `make` for the full target list.

## What's included

| Concern | Tool |
|---|---|
| Engine version | pinned in `.godot-version`, installed project-locally by `tools/install-godot.sh` |
| Lint / format | [gdtoolkit](https://github.com/Scony/godot-gdscript-toolkit) (`gdlintrc`, `.gdformatrc`) via `uvx` |
| Tests | in-repo headless runner: `tests/run_tests.gd`, suites in `tests/unit/` |
| Smoke test | `tools/smoke.sh` boots the main scene headless and fails on any error |
| Screenshots | `tools/capture.gd` renders a scene in a window and saves a PNG |
| Exports | `export_presets.cfg` (Web, Linux, Windows, macOS); `make install-templates`, then `make export-web` etc. |
| CI | `.github/workflows/ci.yml`: lint, test, smoke on every PR; Web export artifact on `main` |
| API reference | `make api-docs` dumps the engine's class reference XML for offline lookup |

## Layout

```
scenes/main.tscn        entry scene
scripts/main.gd         wires rules to the HUD, forwards input
scripts/game/           node-free rules classes (RefCounted), unit-tested
tests/unit/test_*.gd    test suites (extend TestSuite)
tools/                  godot.sh, install-godot.sh, smoke.sh, capture.gd
```

## Starting a new game

1. Rename the project: `config/name` in `project.godot`, `APP_NAME` in the `Makefile`, the export paths
   and bundle identifier in `export_presets.cfg`, and the titles in `CLAUDE.md` and this file.
2. Replace `scripts/game/game_state.gd` (and its test) with your rules, and `scenes/main.tscn` +
   `scripts/main.gd` with your entry scene.
3. `make check` after every change.

## AI assistance

`CLAUDE.md` (symlinked as `AGENTS.md`) gives agents the project map, commands, and conventions.
Project skills live in `.claude/skills/`:

- **godot-dev-loop** — the headless build/lint/test/smoke/screenshot loop and how to read Godot errors.
- **gdscript** — Godot 4 conventions and a Godot 3 → 4 cheat sheet (the most common LLM mistake).
- **godot-scene-files** — safely hand-editing `.tscn`, `.tres`, and input actions.
- **godot-tests** — writing tests with the in-repo runner.
