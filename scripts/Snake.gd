extends Node2D

enum directions { UP, DOWN, LEFT, RIGHT }
var direction
var previous_direction

const TILE_SIZE: int = 16
const OFFSET: int = 8
var tiles: Array = []
var tile_pos: Array = []
var last_pos: Vector2 = Vector2.ZERO
var start_position: Vector2
var can_loop_borders: bool = false

# Play Area limits
var snakelimits_left_top: Vector2
var snakelimits_right_bot: Vector2

onready var snake_tile: PackedScene = preload("res://scenes/SnakeTile.tscn")
onready var snake_head_tile: PackedScene = preload("res://scenes/SnakeHeadTile.tscn")
onready var snake_corner = preload("res://art/snake-corner-tile.png")
onready var snake_corner_alt = preload("res://art/snake-corner-tile-alt.png")
onready var snake_body = preload("res://art/snake-tile.png")
onready var snake_head = preload("res://art/snake-head-tile.png")
onready var snake_tiles = $SnakeTiles

signal snake_died()
signal ate_fruit()
signal ate_special()
signal snake_size_grew()

var alive: bool = true

func _ready() -> void:
	var head = snake_head_tile.instance()
	head.position = start_position
	head.visible = true
	head.set_texture(snake_head)
	snake_tiles.add_child(head)
	tiles.append(head)
	tile_pos.append(head.position)
	emit_signal("snake_size_grew")

	for i in range(3):
		var body_tile = snake_tile.instance()
		body_tile.position = Vector2(start_position.x - TILE_SIZE - TILE_SIZE * i, start_position.y)
		snake_tiles.add_child(body_tile) 
		tiles.append(body_tile)
		tile_pos.append(body_tile.position)
		emit_signal("snake_size_grew")
		body_tile.visible = true

	direction = directions.RIGHT

func set_limits(snakelimits_lt, snakelimits_rb) -> void:
	snakelimits_left_top = snakelimits_lt
	snakelimits_right_bot = snakelimits_rb

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
	if Input.is_action_pressed("grow_snake"):
		eat_fruit()

func calculate_snake_position() -> void:
	var new_pos = Vector2.ZERO

	match direction:
		directions.LEFT:
			new_pos = Vector2(tiles[0].position.x - TILE_SIZE, tiles[0].position.y)
		directions.RIGHT:
			new_pos = Vector2(tiles[0].position.x + TILE_SIZE, tiles[0].position.y)
		directions.UP:
			new_pos = Vector2(tiles[0].position.x, tiles[0].position.y - TILE_SIZE)
		directions.DOWN:
			new_pos = Vector2(tiles[0].position.x, tiles[0].position.y + TILE_SIZE)

	new_pos = check_borders(new_pos)

	if alive:
		tile_pos.pop_back()
		check_for_tail(new_pos)
		tile_pos.push_front(new_pos)

func check_borders(new_pos) -> Vector2:
	if can_loop_borders:
		if new_pos.x >= snakelimits_right_bot.x:
			new_pos.x = snakelimits_left_top.x + OFFSET
		if new_pos.x < snakelimits_left_top.x:
			new_pos.x = snakelimits_right_bot.x - OFFSET
		if new_pos.y > snakelimits_right_bot.y:
			new_pos.y = snakelimits_left_top.y + OFFSET
		if new_pos.y < snakelimits_left_top.y:
			new_pos.y = snakelimits_right_bot.y - OFFSET
	else:
		if new_pos.x >= snakelimits_right_bot.x:
			new_pos.x = snakelimits_right_bot.x
			die()
		if new_pos.x < snakelimits_left_top.x:
			new_pos.x = snakelimits_left_top.x
			die()
		if new_pos.y > snakelimits_right_bot.y:
			new_pos.y = snakelimits_right_bot.y
			die()
		if new_pos.y < snakelimits_left_top.y:
			new_pos.y = snakelimits_left_top.y
			die()
	return new_pos

func draw_snake() -> void:
	tiles[0].position = tile_pos[0]
	for i in range(1, tiles.size()):
		tiles[i].position = tile_pos[i]
		if i > 0:
			tiles[i].set_texture(snake_body)
			tiles[i].flip_v = false
			tiles[i].flip_h = false
			tiles[i].rotation_degrees = 0

			if tile_pos[i - 1].x < tile_pos[i].x:
				var next_tile = i + 1
				if next_tile < tile_pos.size():
					if tile_pos[i + 1].y < tile_pos[i].y:
						tiles[i].set_texture(snake_corner)
						tiles[i].rotation_degrees = 270
					elif tile_pos[i + 1].y > tile_pos[i].y:
						tiles[i].set_texture(snake_corner_alt)
						tiles[i].rotation_degrees = 180
					else:
						tiles[i].flip_v = true
				else:
					tiles[i].flip_v = true
			
			elif tile_pos[i - 1].x > tile_pos[i].x:
				tiles[i].rotation_degrees = 0
				var next_tile = i + 1
				if next_tile < tile_pos.size():
					if tile_pos[i + 1].y < tile_pos[i].y:
						tiles[i].set_texture(snake_corner_alt)
					elif tile_pos[i + 1].y > tile_pos[i].y:
						tiles[i].set_texture(snake_corner)
						tiles[i].rotation_degrees = 90
			# Going up
			elif tile_pos[i - 1].y < tile_pos[i].y:
				var next_tile = i + 1
				if next_tile < tile_pos.size():
					if tile_pos[i + 1].x < tile_pos[i].x:
						tiles[i].set_texture(snake_corner_alt)
						tiles[i].rotation_degrees = 270
					
					elif tile_pos[i + 1].x > tile_pos[i].x:
						tiles[i].set_texture(snake_corner)
						tiles[i].rotation_degrees = 0
					else:
						tiles[i].rotation_degrees = 90
						tiles[i].flip_v = true
				else:
					tiles[i].rotation_degrees = 90
					tiles[i].flip_v = true
			
			# Going Down					
			elif tile_pos[i - 1].y > tile_pos[i].y:
				var next_tile = i + 1
				if next_tile < tile_pos.size():
					if tile_pos[i + 1].x > tile_pos[i].x:
						tiles[i].set_texture(snake_corner_alt)
						tiles[i].rotation_degrees = 90

					elif tile_pos[i + 1].x < tile_pos[i].x:
						tiles[i].set_texture(snake_corner)
						tiles[i].rotation_degrees = 180
					else:
						tiles[i].rotation_degrees = 90
				else:
					tiles[i].rotation_degrees = 90
			
	tiles[-1].visible = true
	
func check_for_fruit(fruit_position) -> void:
	if fruit_position == tile_pos[0]:
		eat_fruit()
		emit_signal("ate_fruit")

func check_for_special(special_position) -> void:
	if special_position == tile_pos[0]:
		emit_signal("ate_special")
		eat_special()

func is_fruit_under_snake(fruit_position) -> bool:
	if tile_pos.has(fruit_position):
		return true
	else:
		return false

func die() -> void:
	alive = false
	tiles[0].get_node("AnimationPlayer").play("Die")
	emit_signal("snake_died")

func check_for_tail(new_pos) -> void:
	if tile_pos.has(new_pos):
		die()

func eat_fruit() -> void:
	var tile = snake_tile.instance()
	tile.position = last_pos
	snake_tiles.add_child(tile)
	tile_pos.append(tile.position)
	tiles.append(tile)
	tiles[0].get_node("AnimationPlayer").play("EatFruit")
	emit_signal("snake_size_grew")

func eat_special() -> void:
	tiles[0].get_node("AnimationPlayer").play("EatSpecial")