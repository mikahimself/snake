extends Node2D

onready var message_title = get_node("ColorRect/MessageContainer/Title")
onready var message_subtitle = get_node("ColorRect/MessageContainer/Subtitle")

enum SCREEN_STATE {
	MAINMENU,
	GAME,
	PAUSE,
	GAMEOVER
}
var screen_state

# Messages
const PAUSE_MESSAGE_TITLE = "PAUSED"
const PAUSE_MESSAGE_SUBTITLE = "PRESS SPACE TO CONTINUE"

const GAME_OVER_MESSAGE_TITLE = "GAME OVER"
const GAME_OVER_MESSAGE_SUBTITLE = ""

const MAIN_MENU_MESSAGE_TITLE = "SNAKE"
const MAIN_MENU_MESSAGE_SUBTITLE = "SYNTHWAVE EDITION"


func _ready() -> void:
	update_screen_state(SCREEN_STATE.MAINMENU)

func _input(event):
	if screen_state == SCREEN_STATE.GAME:
		if event.is_action_pressed("ui_cancel"):
			update_screen_state(SCREEN_STATE.PAUSE)
	if screen_state == SCREEN_STATE.PAUSE:
		if event.is_action_pressed("ui_select"):
			update_screen_state(SCREEN_STATE.GAME)

func update_screen_state(state) -> void:
	screen_state = state
	set_screen_state()

func set_screen_state() -> void:
	match screen_state:
		SCREEN_STATE.MAINMENU:
			visible = true
			message_title.set_text(MAIN_MENU_MESSAGE_TITLE)
			message_subtitle.set_text(MAIN_MENU_MESSAGE_SUBTITLE)
		SCREEN_STATE.PAUSE:
			get_tree().paused = true
			visible = true
			message_title.set_text(PAUSE_MESSAGE_TITLE)
			message_subtitle.set_text(PAUSE_MESSAGE_SUBTITLE)
		SCREEN_STATE.GAMEOVER:
			visible = true
			message_title.set_text(GAME_OVER_MESSAGE_TITLE)
			message_subtitle.set_text(GAME_OVER_MESSAGE_SUBTITLE)
		SCREEN_STATE.GAME:
			visible = false
			get_tree().paused = false
	