extends Node2D

# Arena Size
var rows: int = 25
var cols: int = 25

var pause_state: bool = false

var rng: RandomNumberGenerator

var screen_w: int = 768
var screen_h: int = 432
var tile_size: int = 16
var start_x: int = 120
var start_y: int = 56
var offset: int = 24
var game_on: bool = true
var move_time_step: float = 0.1
var current_move_time: float = 0.0
var snake_length: int = 0
var special_spawn_limit = 10
var special_spawn_divisor = 5

onready var snake_scene: PackedScene = preload("res://scenes/Snake.tscn")
onready var fruit_scene: PackedScene = preload("res://scenes/Fruit.tscn")
onready var special_scene: PackedScene = preload("res://scenes/Special.tscn")
onready var border_scene: PackedScene = preload("res://scenes/BorderTile.tscn")
onready var special_spawn_timer: Timer = get_node("SpecialSpawnTimer")
onready var game_over_screen = get_node("GameOverScreen")

var border_top = preload("res://art/border-tile-top.png")

var snake: Node2D
var fruit: Sprite
var special: Sprite

func _ready():
    rng = RandomNumberGenerator.new()
    rng.randomize()
    spawn_snake()
    spawn_fruit()

func spawn_snake() -> void:
    snake = snake_scene.instance()
    snake.start_position = Vector2(start_x, start_y)
    snake.connect("snake_died", self, "on_snake_dead")
    snake.connect("snake_size_grew", self, "on_snake_grew")
    snake.connect("ate_fruit", self, "on_snake_ate_fruit")
    snake.connect("ate_special", self, "on_snake_ate_special")
    add_child(snake)

func spawn_fruit() -> void:
    fruit = fruit_scene.instance()
    fruit.scale = Vector2.ZERO
    add_child(fruit)
    move_fruit()

func spawn_special() -> void:
    special = special_scene.instance()
    add_child(special)
    move_special()
    
func _draw():
    draw_rect(Rect2(Vector2(16,16), Vector2(400,400)), Color("#01c4e7"))
    draw_rect(Rect2(Vector2(32,32), Vector2(368,368)), Color("#000000"))
   
    draw_rect(Rect2(Vector2(448,16), Vector2(304,400)), Color("#01c4e7"))
    draw_rect(Rect2(Vector2(464,32), Vector2(272,368)), Color("#000000"))
   
    for i in range(2,26):
        draw_line(Vector2(464, i * 16), Vector2(736, i * 16), Color("#c501e2"), 1)
    for i in range(0, 18):
        draw_line(Vector2(i * 16 + 464, 32), Vector2(i * 16 + 464, 400), Color("#c501e2"), 1)

func move_fruit() -> void:
    fruit.scale = Vector2.ZERO
    var new_col = rng.randi_range(2, cols - 3)
    var new_row = rng.randi_range(2, rows - 3)
    var new_pos = Vector2(new_col * tile_size + offset, new_row * tile_size + offset)

    if snake.is_fruit_under_snake(new_pos):
        move_fruit()
    else:
        fruit.position = new_pos

    fruit.get_node("AnimationPlayer").play("Spawn")
    fruit.get_node("AnimationPlayer").queue("Pulse")


func move_special() -> void:
    var new_col = rng.randi_range(2, cols - 3)
    var new_row = rng.randi_range(2, rows - 3)
    var new_pos = Vector2(new_col * tile_size + offset, new_row * tile_size + offset)

    if snake.is_fruit_under_snake(new_pos) or new_pos == fruit.position:
        move_special()
    else:
        special.set_disabled(false)
        special.position = new_pos

func _process(delta) -> void:

    handle_input()

    if game_on:
        snake.check_input()
        current_move_time += delta

        if current_move_time >= move_time_step:
            snake.calculate_snake_position()
            snake.draw_snake()
            snake.check_for_fruit(fruit.position)
            if special and not special.is_disabled():
                snake.check_for_special(special.position)
            current_move_time = 0

func handle_input():
    if Input.is_action_pressed("reset_game"):
        reset_game()
    if Input.is_action_pressed("ui_select") and not game_on:
        reset_game()

func reset_game():
    snake_length = 0
    snake.queue_free()
    fruit.queue_free()
    spawn_snake()
    spawn_fruit()
    get_tree().paused = false
    game_on = true
    game_over_screen.visible = false
    if special:
        special.set_disabled(true)

func on_snake_dead():
    game_on = false
    $GameOverTimer.start()

func on_snake_ate_fruit():
    move_fruit()

func on_snake_ate_special():
    special.set_disabled(true)
    print("ate special")

func on_snake_grew():
    snake_length += 1
    print("Snake len: ", snake_length)
    if snake_length >= special_spawn_limit and snake_length % special_spawn_divisor == 0:
        special_spawn_timer.start()

func _on_SpecialSpawnTimer_timeout():
    spawn_special()

func _on_GameOverTimer_timeout():
    game_over_screen.visible = true