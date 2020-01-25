extends Node

var game_modes: Dictionary = {}
var game_mode: int = 0
var step_times: Array = [0.25, 0.15, 0.10]

func _ready() -> void:
	setup_game_modes()

func setup_game_modes() -> void:
	add_game_mode("EASY")
	add_game_mode("NORMAL")
	add_game_mode("HARD")

func add_game_mode(mode_name) -> void:
	game_modes[game_modes.size()] = mode_name

func set_game_mode():
	game_mode += 1
	if game_mode >= game_modes.size():
		game_mode = 0

func get_game_mode() -> String:
	return game_modes[game_mode]

func get_step_time() -> float:
	return step_times[game_mode]