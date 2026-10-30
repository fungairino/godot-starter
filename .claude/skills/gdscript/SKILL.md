---
name: gdscript
description: GDScript 2.0 (Godot 4) conventions and Godot 3 → 4 pitfalls for this project. Use whenever writing or reviewing .gd files, especially to avoid emitting outdated Godot 3 syntax.
---

# GDScript conventions (Godot 4)

## Godot 3 habits that are WRONG here

| Godot 3 (don't) | Godot 4 (do) |
|---|---|
| `export var speed = 10` | `@export var speed: float = 10.0` |
| `onready var x = $X` | `@onready var x: Node2D = $X` |
| `yield(get_tree(), "idle_frame")` | `await get_tree().process_frame` |
| `yield(timer, "timeout")` | `await timer.timeout` |
| `connect("pressed", self, "_on_pressed")` | `pressed.connect(_on_pressed)` |
| `emit_signal("hit", 1)` | `hit.emit(1)` |
| `scene.instance()` | `scene.instantiate()` |
| `KinematicBody2D`, `move_and_slide(vel, Vector2.UP)` | `CharacterBody2D`; set `velocity`, call `move_and_slide()` |
| `Spatial`, `KinematicBody` | `Node3D`, `CharacterBody3D` |
| `rand_range(a, b)` | `randf_range(a, b)` / `randi_range(a, b)` |
| `setget` | `var x: int: set = _set_x, get = _get_x` (or inline `set(value):`) |
| `tool` | `@tool` |
| `deg2rad`, `stepify` | `deg_to_rad`, `snapped` |
| `PoolStringArray` | `PackedStringArray` |
| `File.new()` / `Directory.new()` | `FileAccess.open(...)` / `DirAccess.open(...)` |
| `funcref(obj, "m")` | `obj.m` (Callable) or `Callable(obj, "m")` |
| `call_deferred("m")` | `m.call_deferred()` |
| `get_tree().change_scene("...")` | `get_tree().change_scene_to_file("...")` |

If unsure whether something exists, grep `.godot-bin/api-docs/` (see `godot-dev-loop`).

## Style

- Tabs for indentation. `snake_case` vars/functions, `PascalCase` classes/nodes, `CONSTANT_CASE` consts.
- Type everything: `var score: int = 0`, `func f(x: float) -> void:`, `var dir := Vector2.ZERO`.
  Use `:=` only when the type is obvious from the right-hand side.
- Private members/methods prefixed `_`. Signal handlers named `_on_<node>_<signal>`.
- Two blank lines between functions (gdformat enforces). Max line length 100.
- Member order (gdlint `class-definitions-order`):
  `@tool` → `class_name` → `extends` → docstring → signals → enums → consts → `@export` vars →
  public vars → private vars → `@onready` vars → `_init`/`_ready`/other virtuals → public funcs → private funcs.
- Add `class_name` only for types other code references (e.g. `GameState`), not for every script.

## Architecture

- **Call down, signal up.** Parents call methods on children; children emit signals the parent connects.
  Example: a view node emits `cell_clicked`; `main.gd` connects it and calls into the rules.
- Connect signals in code (`_ready`) rather than in the `.tscn` `[connection]` block, so wiring is greppable.
- Get nodes with `@onready var x: T = $Path` or `%UniqueName` (needs `unique_name_in_owner = true`
  in the scene). Avoid `get_node("../../Foo")` reaching outside the scene.
- Keep rules in node-free `RefCounted` classes (`scripts/game/`) so tests can drive them directly;
  nodes only draw state and forward input.
- Don't add/remove physics bodies or areas inside physics callbacks (`body_entered`,
  `_physics_process`) — defer with `.call_deferred()`.
- Movement in `_physics_process`, visuals/UI in `_process`. Read input via `Input.get_vector` /
  `event.is_action_pressed(...)` using action names from `project.godot` `[input]`.
