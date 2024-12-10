extends Node2D
@export var level:int = 1
var balls_available = 10 + level
var canShoot = true
var ball_count:int = 0
var canon_location = Vector2(296,1190)
@onready var boost_speed: Timer = $boost_speed
@onready var cannon: Sprite2D = $Cannon

var new_shoot_direction = Vector2()
@onready var tilemap: TileMap = $TileMap


@onready var timer: Timer = $Timer

var balls = preload("res://Scenes/ball.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if check_all_bricks_destroyed():
		print("You Win")
		pull_down_all_balls()
	cannon.position = canon_location
	if Input.is_action_just_released("shoot") and canShoot:
		shoot_balls(get_global_mouse_position())


func shoot_balls(shoot_direction):
	new_shoot_direction = shoot_direction - canon_location
	canShoot = false
	boost_speed.start()
	
	for i in range(balls_available):
		var new_balls = balls.instantiate()
		new_balls.position = canon_location
		add_child(new_balls)
		ball_count += 1
		await get_tree().create_timer(0.05).timeout  # Tiny delay to ensure correct initialization

		

func remove_ball():
	ball_count -= 1
	if ball_count <= 0:
		canShoot = true
		reset_round()


func _on_boost_speed_timeout() -> void:
	for balls in  get_tree().get_nodes_in_group("ball"):
		balls.add_speed(500)
		boost_speed.start()


func show_direction():
	return new_shoot_direction


func check_all_bricks_destroyed() -> bool:
	return get_tree().get_nodes_in_group("brick").is_empty()
	cannon.position.x = 296
	


func pull_down_all_balls():
	for ball in get_tree().get_nodes_in_group("ball"):
		var tween = get_tree().create_tween()
		
		# Animate the ball's position to (320, 1280) over 1 second
		tween.tween_property(ball, "position", Vector2(296, 1190), 0.29)\
			 .set_trans(Tween.TRANS_CUBIC)\
			 .set_ease(Tween.EASE_IN_OUT)


var first_ball_triggered: bool = false

func adjust_canon_position(ball_x_position):
	if not first_ball_triggered:
		canon_location.x = ball_x_position  # Update the cannon's X position
		cannon.position.x = canon_location.x  # Update the cannon's visual position
		print("Cannon position adjusted to: ", canon_location.x)
		first_ball_triggered = true  # Ensure this only happens once


func reset_round():
	first_ball_triggered = false
	canon_location = Vector2(296, 1190)  # Reset to the default position
	cannon.position = canon_location
	canShoot = true
