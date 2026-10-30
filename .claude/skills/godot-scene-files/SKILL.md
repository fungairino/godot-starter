---
name: godot-scene-files
description: How to safely create and hand-edit Godot 4 text scene (.tscn) and resource (.tres) files and project.godot. Use when adding nodes, instancing scenes, wiring resources, or adding input actions without the editor.
---

# Editing .tscn / .tres by hand

Text scenes are safe to edit directly if you respect the format. After editing, run `make import && make smoke`.

## Structure of a .tscn

```
[gd_scene load_steps=4 format=3 uid="uid://..."]      ; load_steps = ext + sub resources + 1

[ext_resource type="Script" uid="uid://..." path="res://scripts/foo.gd" id="1_abc"]
[ext_resource type="PackedScene" path="res://scenes/bar.tscn" id="2_def"]

[sub_resource type="CircleShape2D" id="CircleShape2D_x1"]
radius = 14.0

[node name="Foo" type="Node2D"]                        ; root: no parent attribute
script = ExtResource("1_abc")

[node name="Shape" type="CollisionShape2D" parent="."] ; direct child of root
shape = SubResource("CircleShape2D_x1")

[node name="Label" type="Label" parent="HUD"]          ; path relative to root, no leading "./"

[node name="Bar" parent="." instance=ExtResource("2_def")]   ; instanced scene: no type=

[connection signal="timeout" from="Timer" to="." method="_on_timer_timeout"]
```

## Rules

- **Never invent `uid="uid://..."` values.** Omit `uid` on new `ext_resource`s and headers; Godot fills
  them in on the next editor save. Keep existing uids untouched.
- Resource `id`s are arbitrary strings but must be unique within the file and match every
  `ExtResource("...")` / `SubResource("...")` reference. Declare resources before the nodes that use them.
- Keep `load_steps` accurate when adding or removing resources.
- `parent` paths: `"."` for root children, `"HUD"` / `"HUD/Panel"` deeper. Node order in the file is
  tree order — a parent must appear before its children.
- Only write properties that differ from defaults. Property names are the inspector names in snake_case
  (`offset_left`, `theme_override_font_sizes/font_size`); confirm them in `.godot-bin/api-docs/`.
- To expose a node to its script as `%Name`, add `unique_name_in_owner = true`.
- Prefer composing scenes (instance a `.tscn` as a child) over duplicating node trees.
- Value syntax: `Vector2(1, 2)`, `Color(r, g, b, a)` (0–1 floats), `PackedVector2Array(x1, y1, x2, y2)`,
  `NodePath("Path/To")`, `&"string_name"`.

## project.godot input actions

Add actions under `[input]` by copying an existing action block and changing `physical_keycode`
(uppercase ASCII for letters, e.g. `65` = A; arrows: left 4194319, up 4194320, right 4194321,
down 4194322; Enter 4194309; Space 32; Escape 4194305). Verify with `make smoke` and a test that
calls `Input.action_press("new_action")`.

## .tres resources

```
[gd_resource type="Resource" script_class="EnemyStats" load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/enemy_stats.gd" id="1_s"]

[resource]
script = ExtResource("1_s")
max_health = 10
```

Use custom `Resource` scripts (`class_name EnemyStats extends Resource` with `@export` fields) for
tunable data, then `make import` so the class is registered.
