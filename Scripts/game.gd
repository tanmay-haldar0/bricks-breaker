extends Node2D

@export var level:int = 1
var balls_available = 10 + level
var canShoot = true
var ball_count:int = 0
var canon_location = Vector2(296, 1190)
@onready var boost_speed: Timer = $boost_speed
@onready var cannon: Sprite2D = $Cannon
@onready var bricks: TileMap = $TileMap

var new_shoot_direction = Vector2()
#@onready var tilemap: TileMap = $TileMap
@onready var timer: Timer = $Timer
var block = Vector2(0,105)
var isShooted:bool = false
var first_ball_triggered: bool = false
var balls = preload("res://Scenes/ball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if check_all_bricks_destroyed():
		pull_down_all_balls()
	
	#print(display.x) 
	
	if Input.is_action_just_released("shoot") and canShoot:
		shoot_balls(get_global_mouse_position())
	
	bricks_pull_down()
	
func _physics_process(delta):
	# Update cannon position every frame
	cannon.position = canon_location 


func shoot_balls(shoot_direction):
	reset_round()
	first_ball_triggered = false
	new_shoot_direction = shoot_direction - canon_location
	canShoot = false
	boost_speed.start()
	
	for i in range(balls_available):
		var new_balls = balls.instantiate()
		new_balls.position = canon_location
		add_child(new_balls)
		ball_count += 1
		await get_tree().create_timer(0.05).timeout  # Tiny delay to ensure correct initialization
	
	
	isShooted = true

func remove_ball():
	ball_count -= 1
	if ball_count <= 0:
		canShoot = true  # Allow shooting again
		reset_round()  # Reset the round

func _on_boost_speed_timeout() -> void:
	for balls in get_tree().get_nodes_in_group("ball"):
		balls.add_speed(500)

func show_direction():
	return new_shoot_direction

func check_all_bricks_destroyed() -> bool:
	return get_tree().get_nodes_in_group("brick").is_empty()

func pull_down_all_balls():
	cannon.position = Vector2(296, 1190)
	for ball in get_tree().get_nodes_in_group("ball"):
		var tween = get_tree().create_tween()
		tween.tween_property(ball, "position", Vector2(296, 1190), 0.29)\
			 .set_trans(Tween.TRANS_CUBIC)\
			 .set_ease(Tween.EASE_IN_OUT)

var display = DisplayServer.window_get_size()
var left_bound = 5
var right_bound = display.x - 10

func adjust_canon_position(ball_x_position):
	#print(ball_x_position)
	if ball_x_position < 1080 and ball_x_position > 5:
		
		if not first_ball_triggered:
			var balls = get_tree().get_nodes_in_group("ball")
			for ball in balls:
				if ball is Node2D:  # Ensure the node is of type Node2D
					print("Ball Position: ", ball.position)
				else:
					print("Node is not a Node2D: ", ball)


			canon_location.x = ball_x_position
			await get_tree().create_timer(0.1).timeout  # Small delay
			first_ball_triggered = true

func reset_round():
	first_ball_triggered = false
	
	if get_tree().get_nodes_in_group("ball").is_empty() and first_ball_triggered:
		canon_location = Vector2(296, 1190)  # Reset to default position
	
	canShoot = true  # Allow shooting again

func bricks_pull_down():
	if canShoot and isShooted :
		isShooted = false
		bricks.position += block
