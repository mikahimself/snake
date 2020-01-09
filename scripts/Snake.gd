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
onready var snake_corner_12 = preload("res://art/snake-corner-12.png")
onready var snake_corner_18 = preload("res://art/snake-corner-18.png")
onready var snake_corner_84 = preload("res://art/snake-corner-84.png")
onready var snake_corner_42 = preload("res://art/snake-corner-42.png")
onready var snake_body = preload("res://art/snake-tile.png")
onready var snake_head = preload("res://art/snake-head-tile.png")
onready var snake_tiles = $SnakeTiles

signal snake_died()
signal ate_fruit()

var alive: bool = false

func _ready() -> void:
	var head = snake_tile.instance()
	head.position = start_position
	head.set_texture(snake_head)
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

func calculate_snake_position() -> void:
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

	# Pass to other side of screen
	if new_pos.x >= 776:
		new_pos.x = 8
	if new_pos.x < 0:
		new_pos.x = 760
	if new_pos.y > 424:
		new_pos.y = 8
	if new_pos.y < 0:
		new_pos.y = 424

	tile_pos.pop_back()
	check_for_tail(new_pos)
	tile_pos.push_front(new_pos)

func draw_snake() -> void:
	for i in range(1, tiles.size()):
		tiles[i].position = tile_pos[i]
		if i > 0:
			tiles[i].set_texture(snake_body)
			tiles[0].flip_h = false
			if tile_pos[i - 1].x < tile_pos[i].x:
				tiles[i].rotation_degrees = 0
				var next_tile = i + 1
				if next_tile < tile_pos.size():
					if tile_pos[i + 1].y < tile_pos[i].y:
						tiles[i].set_texture(snake_corner_18)
					elif tile_pos[i + 1].y > tile_pos[i].y:
						tiles[i].set_texture(snake_corner_84)
			elif tile_pos[i - 1].x > tile_pos[i].x:
				tiles[i].rotation_degrees = 0
				var next_tile = i + 1
				if next_tile < tile_pos.size():
					if tile_pos[i + 1].y < tile_pos[i].y:
						tiles[i].set_texture(snake_corner_12)
					elif tile_pos[i + 1].y > tile_pos[i].y:
						tiles[i].set_texture(snake_corner_42)

			elif tile_pos[i - 1].y < tile_pos[i].y:
				var next_tile = i + 1
				if next_tile < tile_pos.size():
					if tile_pos[i + 1].x < tile_pos[i].x:
						tiles[i].set_texture(snake_corner_18)
					elif tile_pos[i + 1].x > tile_pos[i].x:
						tiles[i].set_texture(snake_corner_12)
					else:
						tiles[i].rotation_degrees = 90
				else:
					tiles[i].rotation_degrees = 90
			elif tile_pos[i - 1].y > tile_pos[i].y:
				var next_tile = i + 1
				if next_tile < tile_pos.size():
					if tile_pos[i + 1].x > tile_pos[i].x:
						tiles[i].set_texture(snake_corner_42)
					elif tile_pos[i + 1].x < tile_pos[i].x:
						tiles[i].set_texture(snake_corner_84)
					else:
						tiles[i].rotation_degrees = 90
				else:
					tiles[i].rotation_degrees = 90
						
	set_snake_head()

func set_snake_head() -> void:
	tiles[0].position = tile_pos[0]
	match direction:
		directions.LEFT:
			tiles[0].rotation_degrees = 0
			tiles[0].flip_h = true
		directions.RIGHT:
			tiles[0].rotation_degrees = 0
			tiles[0].flip_h = false
		directions.UP:
			tiles[0].rotation_degrees = -90
			tiles[0].flip_h = false
		directions.DOWN:
			tiles[0].rotation_degrees = 90
			tiles[0].flip_h = false
	
func check_for_fruit(fruit_position) -> void:
	if fruit_position == tile_pos[0]:
		eat_fruit()
		emit_signal("ate_fruit")

func is_fruit_under_snake(fruit_position) -> bool:
	if tile_pos.has(fruit_position):
		return true
	else:
		return false

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
