extends TestSuite

var main: Node2D


func before_each() -> void:
	main = instantiate("res://scenes/main.tscn")


func test_shows_initial_score() -> void:
	assert_true(main.score_label.text.contains("0"))


func test_add_point_updates_label() -> void:
	var before: int = main.state.score
	main.add_point()
	assert_eq(main.state.score, before + main.POINTS_PER_PRESS)
	assert_true(main.score_label.text.contains(str(main.state.score)))


func test_action_adds_a_point() -> void:
	var before: int = main.state.score
	var event := InputEventAction.new()
	event.action = "add_point"
	event.pressed = true
	tree.root.push_input(event)
	assert_eq(main.state.score, before + main.POINTS_PER_PRESS)
