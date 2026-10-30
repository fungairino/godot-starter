extends TestSuite

var state: GameState


func before_each() -> void:
	state = GameState.new()


func test_starts_at_zero() -> void:
	assert_eq(state.score, 0)


func test_add_points_accumulates() -> void:
	state.add_points(3)
	state.add_points(4)
	assert_eq(state.score, 7)


func test_reset_clears_score() -> void:
	state.add_points(5)
	state.reset()
	assert_eq(state.score, 0)
