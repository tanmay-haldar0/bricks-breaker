extends Node2D
@export var level:int = 1
var balls_available = 10 + level
var canShoot = true
var ball_count:int = 0
var canon_location = Vector2(290,1265)
@onready var boost_speed: Timer = $boost_speed

var new_shoot_direction = Vector2()
@onready var tilemap: TileMap = $TileMap


@onready var timer: Timer = $Timer

var balls = preload("res://Scenes/ball.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if check_tilemap_status():
		print("No more tiles in the TileMap")
	else:
		print("Tiles still present in the TileMap")
	
	if Input.is_action_just_released("shoot") and canShoot:
		shoot_balls(get_global_mouse_position())


func shoot_balls(shoot_direction):
	new_shoot_direction =shoot_direction - canon_location
	canShoot = false
	boost_speed.start()
	for i in range(balls_available):
		var new_balls = balls.instantiate()
		new_balls.position = canon_location
		add_child(new_balls)
		ball_count += 1
		timer.start()
		await timer.timeout
		

func remove_ball():
	ball_count -= 1
	if ball_count <= 0:
		canShoot = true


func _on_boost_speed_timeout() -> void:
	for balls in  get_tree().get_nodes_in_group("ball"):
		balls.add_speed(1000)
		boost_speed.start()


func show_direction():
	return new_shoot_direction




# Function to check if TileMap has no tiles left
func check_tilemap_status():
	# Detailed debugging function
	if tilemap == null:
		print("ERROR: TileMap is null")
		return

	# Basic information about the TileMap
	print("TileMap Layers: ", tilemap.get_layers_count())
	print("Used Rect: ", tilemap.get_used_rect())

	# Check each layer explicitly
	for layer in tilemap.get_layers_count():
		print("Checking Layer ", layer)
		
		# Get used cells for this layer
		var used_cells = tilemap.get_used_cells(layer)
		print("Used Cells in Layer ", layer, ": ", used_cells)
		
		# Check each cell individually
		if not used_cells.is_empty():
			for cell in used_cells:
				var tile_data = tilemap.get_cell_tile_data(layer, cell)
				print("Cell ", cell, " Tile Data: ", tile_data)

	# Alternative method to check tiles
	var total_tiles = 0
	for layer in tilemap.get_layers_count():
		var layer_tiles = tilemap.get_used_cells(layer).size()
		total_tiles += layer_tiles
		print("Tiles in Layer ", layer, ": ", layer_tiles)

	print("Total Tiles: ", total_tiles)
