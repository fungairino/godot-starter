class_name GameState
extends RefCounted
## Example rules object: pure state, no nodes, fully unit-tested.
## Replace this with your game's rules. Keep rules node-free so tests can drive them directly.

var score: int = 0


func add_points(amount: int) -> void:
	assert(amount > 0, "amount must be positive")
	score += amount


func reset() -> void:
	score = 0
