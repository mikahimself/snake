extends Node2D

enum directions { UP, DOWN, LEFT, RIGHT }
var direction
var move_time_step = 0.025
var current_move_time: float = 0.0
var tile_size: int = 16
var tiles: Array = []
var tile_pos: Array = []
var last_pos: Vector2 = Vector2.ZERO

onready var snake_tile = preload("res://scenes/SnakeTile.tscn")


func _ready():
	var tile = snake_tile.instance()
	tile.position = Vector2(position.x, position.y)
	add_child(tile)
	tiles.append(tile)
	tile_pos.append(tile.position)
	
	direction = directions.RIGHT

func _process(delta):
	current_move_time += delta

	if current_move_time >= move_time_step:
		move_snake()
		current_move_time = 0

func _input(event):
	if event.is_action_pressed("ui_left"):
		direction = directions.LEFT
	if event.is_action_pressed("ui_right"):
		direction = directions.RIGHT
	if event.is_action_pressed("ui_up"):
		direction = directions.UP
	if event.is_action_pressed("ui_down"):
		direction = directions.DOWN
	if event.is_action_pressed("ui_select"):
		eat_fruit()

func move_snake():

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
	
	if new_pos.x >= 772:
		new_pos.x = 4
	if new_pos.x <= -4:
		new_pos.x = 772
	if new_pos.y > 432:
		new_pos.y = 4
	if new_pos.y < 0:
		new_pos.y = 436

	tile_pos.pop_back()
	tile_pos.push_front(new_pos)

	for i in range(0, tiles.size()):
		tiles[i].position = tile_pos[i]
	
func eat_fruit():
	var tile = snake_tile.instance()
	tile.position = last_pos
	add_child(tile)
	tile_pos.append(tile.position)
	tiles.append(tile)
