extends Node2D

var pause_state: bool = false

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		pause_state = true
		get_tree().paused = pause_state
		visible = pause_state

	if event.is_action_pressed("ui_select"):
		pause_state = false
		get_tree().paused = false
		visible = false