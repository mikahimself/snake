extends Node2D

onready var side_panel = get_parent().get_node("SidePanel")
onready var button_container: VBoxContainer = get_parent().get_node("SidePanel").get_node("ControlVBox")
var start_button: Button
var mode_button: Button
var menu_active: bool = false

signal game_start_clicked

func _ready():
	start_button = side_panel.get_node("ControlVBox/StartButton")
	start_button.connect("pressed", self, "on_start_button_pressed")
	mode_button = side_panel.get_node("ControlVBox/ModeButton")
	mode_button.set_text("MODE: " + Settings.get_game_mode())
	mode_button.connect("pressed", self, "on_mode_button_pressed")
	mode_button.grab_focus()

func on_start_button_pressed() -> void:
	if menu_active:
		emit_signal("game_start_clicked")

func on_mode_button_pressed() -> void:
	Settings.set_game_mode()
	mode_button.set_text("MODE: " + Settings.get_game_mode())

func set_menu_active(active: bool) -> void:
	menu_active = active
	button_container.visible = menu_active
	mode_button.grab_focus()