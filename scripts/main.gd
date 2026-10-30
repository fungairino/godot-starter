extends Node2D
## Entry scene: wires the GameState rules to the HUD and forwards input.

const POINTS_PER_PRESS := 1

var state: GameState = GameState.new()

@onready var score_label: Label = %ScoreLabel
@onready var hint_label: Label = %HintLabel


func _ready() -> void:
	hint_label.text = "Press Space to add a point. Replace this scene with your game."
	refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("add_point"):
		add_point()


func add_point() -> void:
	state.add_points(POINTS_PER_PRESS)
	refresh()


func refresh() -> void:
	score_label.text = "Score: %d" % state.score
