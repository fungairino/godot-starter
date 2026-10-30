## Base class for tests run by tests/run_tests.gd.
## Methods named test_* are run in order; each may `await`.
class_name TestSuite
extends RefCounted

var tree: SceneTree
var failures: Array[String] = []
var _owned_nodes: Array[Node] = []


func before_each() -> void:
	pass


func after_each() -> void:
	pass


## Adds a node to the scene tree; it is freed automatically after the test.
func add_to_tree(node: Node) -> Node:
	tree.root.add_child(node)
	_owned_nodes.append(node)
	return node


func instantiate(scene_path: String) -> Node:
	var scene: PackedScene = load(scene_path)
	return add_to_tree(scene.instantiate())


func wait_physics_frames(count: int) -> void:
	for i in count:
		await tree.physics_frame


func wait_frames(count: int) -> void:
	for i in count:
		await tree.process_frame


func free_owned_nodes() -> void:
	for node in _owned_nodes:
		if is_instance_valid(node):
			node.free()
	_owned_nodes.clear()


func fail(message: String) -> void:
	failures.append(message)


func assert_true(condition: bool, message: String = "expected true") -> void:
	if not condition:
		fail(message)


func assert_false(condition: bool, message: String = "expected false") -> void:
	if condition:
		fail(message)


func assert_eq(actual: Variant, expected: Variant, message: String = "") -> void:
	if actual != expected:
		fail("%sexpected %s, got %s" % [_prefix(message), expected, actual])


func assert_ne(actual: Variant, unexpected: Variant, message: String = "") -> void:
	if actual == unexpected:
		fail("%sdid not expect %s" % [_prefix(message), unexpected])


func assert_almost_eq(
	actual: float, expected: float, tolerance: float = 0.001, message: String = ""
) -> void:
	if absf(actual - expected) > tolerance:
		fail("%sexpected %s ± %s, got %s" % [_prefix(message), expected, tolerance, actual])


func _prefix(message: String) -> String:
	return message + ": " if message else ""
