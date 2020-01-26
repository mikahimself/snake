extends Node2D

onready var side_panel = get_parent().get_node("SidePanel")
onready var button_container: VBoxContainer = get_parent().get_node("SidePanel").get_node("ControlVBox")
onready var audio_select: AudioStreamPlayer = get_node("AudioSelect")
var start_button: Button
var mode_button: Button
var menu_active: bool = false

signal game_start_clicked

func _ready():
	start_button = side_panel.get_node("ControlVBox/StartButton")
	start_button.connect("pressed", self, "on_start_button_pressed")
	start_button.connect("focus_entered", self, "on_start_button_focus_entered")
	mode_button = side_panel.get_node("ControlVBox/ModeButton")
	mode_button.set_text("MODE: " + Settings.get_game_mode())
	mode_button.grab_focus()
	mode_button.connect("pressed", self, "on_mode_button_pressed")
	mode_button.connect("focus_entered", self, "on_mode_button_focus_entered")
	

func on_start_button_pressed() -> void:
	if menu_active:
		emit_signal("game_start_clicked")
		audio_select.play()

func on_start_button_focus_entered() -> void:
	audio_select.play()

func on_mode_button_pressed() -> void:
	if menu_active:
		audio_select.play()
		Settings.set_game_mode()
		mode_button.set_text("MODE: " + Settings.get_game_mode())

func on_mode_button_focus_entered() -> void:
	audio_select.play()

func set_menu_active(active: bool) -> void:
	menu_active = active
	button_container.visible = menu_active
	mode_button.grab_focus()