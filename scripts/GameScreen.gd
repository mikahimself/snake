extends Node2D

var screen_w: int = 768
var screen_h: int = 432
var tile_size: int = 16
var start_x: int = 24
var start_y: int = 24
var offset: int = 8
var game_on: bool = true
var move_time_step: float = 0.1
var current_move_time: float = 0.0

onready var snake_scene: PackedScene = preload("res://scenes/Snake.tscn")
onready var fruit_scene: PackedScene = preload("res://scenes/Fruit.tscn")
var snake: Node2D
var fruit: Sprite

func _ready():
    randomize()
    spawn_snake()
    spawn_fruit()

func spawn_snake() -> void:
    snake = snake_scene.instance()
    snake.start_position = Vector2(start_x, start_y)
    snake.connect("snake_died", self, "on_snake_dead")
    snake.connect("ate_fruit", self, "on_snake_eat")
    add_child(snake)

func spawn_fruit() -> void:
    fruit = fruit_scene.instance()
    add_child(fruit)
    move_fruit()
    
func move_fruit() -> void:
    var cols = screen_w / tile_size
    var rows = screen_h / tile_size
    var new_col = randi() % cols
    var new_row = randi() % rows
    var new_pos = Vector2(new_col * tile_size + offset, new_row * tile_size + offset)

    if snake.is_fruit_under_snake(new_pos):
        move_fruit()
    else:
        fruit.position = new_pos

func _process(delta) -> void:
    if game_on:
        snake.check_input()
        current_move_time += delta

        if current_move_time >= move_time_step:
            snake.calculate_snake_position()
            snake.draw_snake()
            snake.check_for_fruit(fruit.position)
            current_move_time = 0

func on_snake_dead():
    game_on = false

func on_snake_eat():
    move_fruit()