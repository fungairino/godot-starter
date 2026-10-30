---
name: godot-tests
description: Write and run headless unit/integration tests for this Godot project using its built-in TestSuite runner. Use when adding gameplay logic, fixing a bug, or when asked to add or debug tests.
---

# Writing tests

Tests use a tiny in-repo framework (no addons): `tests/test_suite.gd` + `tests/run_tests.gd`.

## Add a suite

Create `tests/unit/test_<thing>.gd`:

```gdscript
extends TestSuite

var main: Node2D


func before_each() -> void:
	main = instantiate("res://scenes/main.tscn")  # added to tree, freed after each test


func test_starts_at_zero() -> void:
	assert_eq(main.state.score, 0)


func test_action_adds_a_point() -> void:
	var event := InputEventAction.new()
	event.action = "add_point"
	event.pressed = true
	tree.root.push_input(event)  # synchronous: goes through _input/_unhandled_input
	assert_eq(main.state.score, 1)
```

Then `make import` (new script), `make test FILTER=test_<thing>`, and finally `make check`.

## API

- Hooks: `before_each()`, `after_each()`. Each `test_*` method runs in declaration order and may `await`.
- Tree: `instantiate(path)`, `add_to_tree(node)`, `tree` (the `SceneTree`).
- Waiting: `await wait_frames(n)`, `await wait_physics_frames(n)`.
- Asserts: `assert_true`, `assert_false`, `assert_eq`, `assert_ne`, `assert_almost_eq`, `fail(msg)`.
  Asserts record a failure and continue; they don't abort the test.
- Filter: `make test FILTER=substring` matches against `file::test_name`.

## Test behavior, not tuning

A test should fail when a rule breaks, not when someone retunes the game. Balance numbers (level
tables, damage, costs, reward amounts) change often. Literal copies of them in tests break on every
tweak and protect nothing.

- **Assert relationships, not literals.** Use the source of truth or the before/after change:
  ```gdscript
  # Bad: breaks when the per-press amount is retuned.
  assert_eq(main.state.score, 1)
  # Good: states the rule — one press adds POINTS_PER_PRESS.
  var before: int = main.state.score
  main.add_point()
  assert_eq(main.state.score, before + main.POINTS_PER_PRESS)
  ```
- **Choose your own inputs.** Where a rule takes a number, set it in the test and assert against that
  value, not against what a config table happens to hold today.
- **Check generated content against its config.** Loop over the config and compare with each entry;
  don't hard-code "level 1 has 3 enemies" or "there are 5 levels".
- **Don't pin design choices that are pure tuning.** Only test a config decision when code depends on it.
- **Literals are fine for geometry and fixed math**: distances, rotations, a formula's output for
  inputs the test passes in.
- **Assert outcomes the player sees**: state changes, phase changes, an action rejected (returns false
  and nothing changes). Avoid private fields and incidental state such as message text.
- **One behavior per test**, named after the rule (`test_reset_clears_score`, not `test_score_2`).

## Tips

- Test rules on `RefCounted` classes in `scripts/game/` directly (see `tests/unit/test_game_state.gd`);
  keep scene tests (`instantiate("res://scenes/main.tscn")`) to wiring: clicks, buttons, labels.
- Release any `Input.action_press` in `after_each()` — input state is global across tests.
- Anything done via `call_deferred` needs `await wait_frames(1)` before asserting.
- When fixing a bug, write the failing test first and confirm it fails.
- If the suite outgrows this, GUT (github.com/bitwes/Gut) or gdUnit4 can be added as addons.
