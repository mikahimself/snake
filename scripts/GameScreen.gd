extends Node2D

# Arena Size
var rows: int = 23
var cols: int = 23

var pause_state: bool = false

var rng: RandomNumberGenerator

const TILE_SIZE: int = 16
const START_X: int = 120
const START_Y: int = 56
const OFFSET: int = 8

# Game Area
const ORIGIN_PLAYAREA_OUTER: Vector2 = Vector2(16, 16)
const ORIGIN_PLAYAREA_INNER: Vector2 = Vector2(32, 32)
const RECTSIZE_PLAYAREA_OUTER: Vector2 = Vector2(400, 400)
const RECTSIZE_PLAYAREA_INNER: Vector2 = Vector2(368, 368)

# Movement Limits for Snake
var snakelimits_left_top: Vector2 = Vector2(ORIGIN_PLAYAREA_INNER.x, ORIGIN_PLAYAREA_INNER.y)
var snakelimits_right_bot: Vector2 = Vector2(ORIGIN_PLAYAREA_INNER.x + RECTSIZE_PLAYAREA_INNER.x, ORIGIN_PLAYAREA_INNER.y + RECTSIZE_PLAYAREA_INNER.y)

var game_on: bool = true
var move_time_step: float = 0.5
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

var snake: Node2D
var fruit: Sprite
var special: Sprite

func _ready() -> void:
    rng = RandomNumberGenerator.new()
    rng.randomize()
    spawn_snake()
    spawn_fruit()

func spawn_snake() -> void:
    snake = snake_scene.instance()
    snake.start_position = Vector2(START_X, START_Y)
    snake.set_limits(snakelimits_left_top, snakelimits_right_bot)
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
    
func _draw() -> void:
    draw_rect(Rect2(ORIGIN_PLAYAREA_OUTER, RECTSIZE_PLAYAREA_OUTER), Color("#01c4e7"))
    draw_rect(Rect2(ORIGIN_PLAYAREA_INNER, RECTSIZE_PLAYAREA_INNER), Color("#000000"))
   
    draw_rect(Rect2(Vector2(448,16), Vector2(304,400)), Color("#01c4e7"))
    draw_rect(Rect2(Vector2(464,32), Vector2(272,368)), Color("#000000"))
   
    for i in range(2,26):
        draw_line(Vector2(464, i * TILE_SIZE), Vector2(736, i * TILE_SIZE), Color("#c501e2"), 1)
    for i in range(0, 18):
        draw_line(Vector2(i * TILE_SIZE + 464, 32), Vector2(i * TILE_SIZE + 464, 400), Color("#c501e2"), 1)

func move_fruit() -> void:
    fruit.scale = Vector2.ZERO
    var new_col = rng.randi_range(1, cols - 2)
    var new_row = rng.randi_range(1, rows - 2)
    var new_pos = Vector2(ORIGIN_PLAYAREA_INNER.x + TILE_SIZE * new_col + OFFSET, ORIGIN_PLAYAREA_INNER.y + TILE_SIZE * new_col + OFFSET)
    
    if snake.is_fruit_under_snake(new_pos):
        move_fruit()
    else:
        fruit.position = new_pos

    fruit.get_node("AnimationPlayer").play("Spawn")
    fruit.get_node("AnimationPlayer").queue("Pulse")


func move_special() -> void:
    var new_col = rng.randi_range(1, cols - 2)
    var new_row = rng.randi_range(1, rows - 2)
    var new_pos = Vector2(ORIGIN_PLAYAREA_INNER.x + TILE_SIZE * new_col + OFFSET, ORIGIN_PLAYAREA_INNER.y + TILE_SIZE * new_col + OFFSET)

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

func handle_input() -> void:
    if Input.is_action_pressed("reset_game"):
        reset_game()
    if Input.is_action_pressed("ui_select") and not game_on:
        reset_game()

func reset_game() -> void:
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

func on_snake_dead() -> void:
    game_on = false
    $GameOverTimer.start()

func on_snake_ate_fruit() -> void:
    move_fruit()

func on_snake_ate_special() -> void:
    special.set_disabled(true)
    print("ate special")

func on_snake_grew() -> void:
    snake_length += 1
    print("Snake len: ", snake_length)
    if snake_length >= special_spawn_limit and snake_length % special_spawn_divisor == 0:
        special_spawn_timer.start()

func _on_SpecialSpawnTimer_timeout() -> void:
    spawn_special()

func _on_GameOverTimer_timeout() -> void:
    game_over_screen.visible = true