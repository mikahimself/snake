extends Node2D

onready var score_panel = get_parent().get_node("ScorePanel")

var score: int = 0
var length: int = 0
const SCORE_FRUIT: int = 10
const SCORE_SPECIAL: int = 50
const SPECIAL_SPAWN_MIN_LIMIT = 10
const SPECIAL_SPAWN_DIVISOR = 10

signal spawn_special_limit_reached

func on_snake_ate_fruit() -> void:
	score += SCORE_FRUIT
	score_panel.set_score(score)

func on_snake_ate_special() -> void:
	score += SCORE_SPECIAL
	score_panel.set_score(score)

func on_snake_grew() -> void:
	length += 1
	score_panel.set_length(length)

	if length >= SPECIAL_SPAWN_MIN_LIMIT and length % SPECIAL_SPAWN_DIVISOR == 0:
		emit_signal("spawn_special_limit_reached")

func reset_score() -> void:
	score = 0
	length = 0