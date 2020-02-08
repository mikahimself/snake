extends Node2D

const TILE_SIZE: int = 16
const START_X: int = 120
const START_Y: int = 56
const OFFSET: int = 8

# Game Area
const ORIGIN_PLAYAREA_OUTER: Vector2 = Vector2(16, 16)
const ORIGIN_PLAYAREA_INNER: Vector2 = Vector2(32, 32)
const RECTSIZE_PLAYAREA_OUTER: Vector2 = Vector2(400, 400)
const RECTSIZE_PLAYAREA_INNER: Vector2 = Vector2(368, 368)
var rows: int = RECTSIZE_PLAYAREA_INNER.y / TILE_SIZE
var cols: int = RECTSIZE_PLAYAREA_INNER.x / TILE_SIZE

# Sidepanel Area
const ORIGIN_SIDEPANEL_OUTER: Vector2 = Vector2(448, 16)
const ORIGIN_SIDEPANEL_INNER: Vector2 = Vector2(464, 32)
const RECTSIZE_SIDEPANEL_OUTER: Vector2 = Vector2(304, 400)
const RECTSIZE_SIDEPANEL_INNER: Vector2 = Vector2(272, 368)

# Colors
const COLOR_BLUE: Color = Color("#01c4e7")
const COLOR_BLACK: Color = Color("#000000")
const COLOR_RED: Color = Color("#c501e2")

# Movement Limits for Snake
var snakelimits_left_top: Vector2 = Vector2(ORIGIN_PLAYAREA_INNER.x, ORIGIN_PLAYAREA_INNER.y)
var snakelimits_right_bot: Vector2 = Vector2(ORIGIN_PLAYAREA_INNER.x + RECTSIZE_PLAYAREA_INNER.x, ORIGIN_PLAYAREA_INNER.y + RECTSIZE_PLAYAREA_INNER.y)

# Gameplay related
var game_on: bool = false
var move_time_step: float = 0.25
var current_move_time: float = 0.0

# Scenes and Nodes
onready var snake_scene: PackedScene = preload("res://scenes/Snake.tscn")
onready var fruit_scene: PackedScene = preload("res://scenes/Fruit.tscn")
onready var special_scene: PackedScene = preload("res://scenes/Special.tscn")
onready var special_spawn_timer: Timer = get_node("SpecialSpawnTimer")
onready var message_screen = get_node("MessageScreen")
onready var score_handler = get_node("ScoreHandler")
onready var menu_handler = get_node("MenuHandler")

var snake: Node2D
var fruit: Sprite
var special: Sprite
var rng: RandomNumberGenerator

func _ready() -> void:
    rng = RandomNumberGenerator.new()
    rng.randomize()
    score_handler.connect("spawn_special_limit_reached", self, "on_spawn_special_limit_reached")
    menu_handler.connect("game_start_clicked", self, "start_game")
    menu_handler.set_menu_active(true)
    score_handler.load_high_score()

func start_game() -> void:
    game_on = true
    update()
    score_handler.reset_score()
    set_step_time()
    spawn_snake()
    spawn_fruit()
    get_tree().paused = false
    game_on = true
    message_screen.update_screen_state(message_screen.SCREEN_STATE.GAME)
    menu_handler.set_menu_active(false)
    if special:
        special.set_disabled(true)

func set_step_time() -> void:
    move_time_step = Settings.get_step_time()

func spawn_snake() -> void:
    snake = snake_scene.instance()
    snake.start_position = Vector2(START_X, START_Y)
    snake.set_limits(snakelimits_left_top, snakelimits_right_bot)
    snake.connect("snake_died", self, "on_snake_dead")
    snake.connect("snake_size_grew", score_handler, "on_snake_grew")
    snake.connect("ate_fruit", score_handler, "on_snake_ate_fruit")
    snake.connect("ate_fruit", self, "on_snake_ate_fruit")
    snake.connect("ate_special", score_handler, "on_snake_ate_special")
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
    draw_rect(Rect2(ORIGIN_PLAYAREA_OUTER, RECTSIZE_PLAYAREA_OUTER), COLOR_BLUE)
    draw_rect(Rect2(ORIGIN_PLAYAREA_INNER, RECTSIZE_PLAYAREA_INNER), COLOR_BLACK)
   
    draw_rect(Rect2(ORIGIN_SIDEPANEL_OUTER, RECTSIZE_SIDEPANEL_OUTER), COLOR_BLUE)
    draw_rect(Rect2(ORIGIN_SIDEPANEL_INNER, RECTSIZE_SIDEPANEL_INNER), COLOR_BLACK)
   
    for i in range(2,26):
        if game_on:
            if i != 4 and i != 7:
                draw_line(Vector2(ORIGIN_SIDEPANEL_INNER.x, i * TILE_SIZE), Vector2(ORIGIN_SIDEPANEL_INNER.x + RECTSIZE_SIDEPANEL_INNER.x, i * TILE_SIZE), COLOR_RED, 1)
        else:
            if i != 4 and i != 7 and i != 19 and i != 22:
                draw_line(Vector2(ORIGIN_SIDEPANEL_INNER.x, i * TILE_SIZE), Vector2(ORIGIN_SIDEPANEL_INNER.x + RECTSIZE_SIDEPANEL_INNER.x, i * TILE_SIZE), COLOR_RED, 1)
    for i in range(0, 18):
        draw_line(Vector2(i * TILE_SIZE + ORIGIN_SIDEPANEL_INNER.x, ORIGIN_SIDEPANEL_INNER.y), Vector2(i * TILE_SIZE + ORIGIN_SIDEPANEL_INNER.x, 400), COLOR_RED, 1)

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
    if game_on:
        current_move_time += delta
        snake.check_input()

        if current_move_time >= move_time_step:
            snake.calculate_snake_position()
            snake.draw_snake()
            snake.check_for_fruit(fruit.position)
            if special and not special.is_disabled():
                snake.check_for_special(special.position)
            current_move_time = 0

func on_snake_dead() -> void:
    game_on = false
    score_handler.save_high_score()
    $GameOverTimer.start()

func _on_SpecialSpawnTimer_timeout() -> void:
    spawn_special()

func _on_GameOverTimer_timeout() -> void:
    message_screen.update_screen_state(message_screen.SCREEN_STATE.GAMEOVER)
    menu_handler.set_menu_active(true)
    score_handler.load_high_score()
    snake.queue_free()
    fruit.queue_free()
    update()

func on_spawn_special_limit_reached() -> void:
    special_spawn_timer.start()

func on_snake_ate_fruit() -> void:
    move_fruit()

func on_snake_ate_special() -> void:
    special.set_disabled(true)
