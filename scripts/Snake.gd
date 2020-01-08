extends Node2D

enum directions { UP, DOWN, LEFT, RIGHT }
var direction
var previous_direction

var tile_size: int = 16
var tiles: Array = []
var tile_pos: Array = []
var last_pos: Vector2 = Vector2.ZERO
var start_position: Vector2

onready var snake_tile: PackedScene = preload("res://scenes/SnakeTile.tscn")
onready var snake_tiles = $SnakeTiles

signal snake_died()
signal ate_fruit()

var alive: bool = false

func _ready() -> void:
	var head = snake_tile.instance()
	head.position = start_position
	snake_tiles.add_child(head)
	tiles.append(head)
	tile_pos.append(head.position)
	direction = directions.RIGHT

func check_input() -> void:

	previous_direction = direction

	if Input.is_action_pressed("ui_left") and direction != directions.RIGHT:
		direction = directions.LEFT
	if Input.is_action_pressed("ui_right") and direction != directions.LEFT:
		direction = directions.RIGHT
	if Input.is_action_pressed("ui_up") and direction != directions.DOWN:
		direction = directions.UP
	if Input.is_action_pressed("ui_down") and direction != directions.UP:
		direction = directions.DOWN
	if Input.is_action_pressed("ui_select"):
		eat_fruit()

func move_snake() -> void:

	last_pos = tile_pos[-1]
	var new_pos = Vector2.ZERO

	match direction:
		directions.LEFT:
			new_pos = Vector2(tiles[0].position.x - tile_size, tiles[0].position.y)
		directions.RIGHT:
			new_pos = Vector2(tiles[0].position.x + tile_size, tiles[0].position.y)
		directions.UP:
			new_pos = Vector2(tiles[0].position.x, tiles[0].position.y - tile_size)
		directions.DOWN:
			new_pos = Vector2(tiles[0].position.x, tiles[0].position.y + tile_size)
	
	if new_pos.x >= 768:
		new_pos.x = 0
	if new_pos.x < 0:
		new_pos.x = 752
	if new_pos.y > 416:
		new_pos.y = 0
	if new_pos.y < 0:
		new_pos.y = 416

	tile_pos.pop_back()
	check_for_tail(new_pos)
	tile_pos.push_front(new_pos)

	for i in range(0, tiles.size()):
		tiles[i].position = tile_pos[i]

	print(tile_pos[0])
	
func check_for_fruit(fruit_position) -> void:
	if fruit_position == tile_pos[0]:
		eat_fruit()
		emit_signal("ate_fruit")

func check_for_tail(new_pos) -> void:
	if tile_pos.has(new_pos):
		alive = false
		emit_signal("snake_died")

func eat_fruit():
	var tile = snake_tile.instance()
	tile.position = last_pos
	snake_tiles.add_child(tile)
	tile_pos.append(tile.position)
	tiles.append(tile)
