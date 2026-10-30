---
name: godot-dev-loop
description: Build, run, lint, test, and verify changes in this Godot project from the command line. Use after editing any .gd, .tscn, .tres, or project.godot file, when a Godot command fails, or when asked to run, test, or check the game.
---

# Godot dev loop

You can't see the game window, so verification is headless. Every change ends with `make check`.

## The loop

1. Edit scripts/scenes.
2. If you added or renamed a `class_name`, added an asset, or created a new scene: `make import`.
3. `make format` (fixes formatting; never hand-fight gdformat).
4. `make check` — runs `lint`, `format-check`, `test`, `smoke` in that order.
5. Fix the first failure, repeat. Don't report done with a red `make check`.

## Reading failures

| Output | Meaning | Fix |
|---|---|---|
| `Parse Error: Identifier "Foo" not declared` | class cache stale, or typo | `make import`; then check spelling |
| `Could not find type "Foo"` in a test | same as above | `make import` |
| `Invalid get index 'x' (on base: 'Nil')` | `@onready`/`$Path` didn't resolve | node path in script vs `.tscn` mismatch |
| `Can't change this state while flushing queries` | add/remove physics node in a physics callback | use `.call_deferred()` |
| `Failed to load resource` | wrong `res://` path or deleted file | grep for the path; fix ext_resource |
| gdlint `class-definitions-order` | members out of order | see the `gdscript` skill for the order |
| `FAIL test_x::test_y` + message | assertion failed | read the expected/got line |

The smoke test (`tools/smoke.sh`) greps for `SCRIPT ERROR`, `ERROR:`, `Parse Error`, `Failed to load`.
Pass more frames or a different scene: `tools/smoke.sh 600 res://scenes/main.tscn`.

## Seeing the game

Headless runs can't render, so use the screenshot tool after any visual change:

```sh
make screenshot                                   # main scene after 5 frames
make screenshot ARGS="--frames=60"                # let animations/tweens settle
make screenshot ARGS="--scene=res://scenes/x.tscn --out=build/screenshots/x.png"
```

It briefly opens a window, runs the scene for N frames, and saves `build/screenshots/capture.png`
(`--out=` to change). Read the PNG to check the result. Extend `tools/capture.gd` with game-specific
options (a seed, a scripted sequence of moves) so before/after captures are reproducible. It needs a
display; on a headless CI box it will fail.

## Running Godot directly

`tools/godot.sh <args>` runs the pinned Godot with `--path` set to the project. Useful flags:

- `--headless` — no window (always use this yourself).
- `--quit-after N` — exit after N frames.
- `-s res://path/script.gd` — run a script extending `SceneTree` or `MainLoop`.
- `--check-only -s res://scripts/foo.gd` — parse a single script without running it.
- `--print-path` (wrapper only) — print the resolved binary.

To probe engine behavior quickly, write a throwaway script extending `SceneTree` inside the project
(e.g. `tests/tmp_probe.gd`), run it with `-s`, then delete it and its `.uid`.

## Looking up APIs

Run `make api-docs` once, then grep the XML for the pinned version:

```sh
grep -n 'name="move_and_slide"' -A 12 .godot-bin/api-docs/doc/classes/CharacterBody2D.xml
ls .godot-bin/api-docs/doc/classes | grep -i tween
```

GDScript built-ins (`randf_range`, `@export`, …) are in
`.godot-bin/api-docs/modules/gdscript/doc_classes/@GDScript.xml`; global functions and enums are in
`.godot-bin/api-docs/doc/classes/@GlobalScope.xml`.

## Exports

`make install-templates` (one-time, large download), then `make export-web` / `export-linux` /
`export-windows` / `export-macos`. Presets live in `export_presets.cfg`; tests are excluded via
`exclude_filter="tests/*"`.
