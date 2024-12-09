extends Node2D
@export var level:int = 1
var balls_available = 10 + level
var canShoot = true
var ball_count:int = 0
var canon_location = Vector2(290,1265)
@onready var boost_speed: Timer = $boost_speed

var new_shoot_direction = Vector2()


@onready var timer: Timer = $Timer

var balls = preload("res://Scenes/ball.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
