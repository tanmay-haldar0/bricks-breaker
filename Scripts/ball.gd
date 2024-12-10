extends RigidBody2D

var speed: int = 1000
var shoot_direction = Vector2()
var first_ball_triggered: bool = false

func _ready() -> void:
	shoot_direction = get_parent().show_direction()
	shoot_direction += Vector2(randf_range(-10, 10), randf_range(-30, -10))  # Small offset to avoid horizontal loop
	
	# Ensure the shoot direction is properly normalized and applied
	shoot_direction = shoot_direction.normalized() * speed
	apply_central_impulse(shoot_direction)
	set_sleeping(false)  # Make sure the ball doesn't sleep


func _process(delta):
	print("Ball position: ", position, ", Velocity: ", linear_velocity)
	set_sleeping(false)
	# If the ball is close to the bottom and hasn't triggered the cannon position update
	if position.y >= 1100 and not get_parent().first_ball_triggered:
		get_parent().adjust_canon_position(position.x)  # Update cannon position immediately
		get_parent().first_ball_triggered = true  # Ensure this only happens once

	# If the ball goes out of bounds, remove it
	if position.x < -10 or position.x > 680 or position.y > 1500:
		get_parent().remove_ball()
		queue_free()
	


func _on_body_entered(body):
	if body.is_in_group("brick"):
		body.take_life()
		reflect_velocity_with_limit((position - body.position).normalized())
	
	if body.is_in_group("bottom"):
		get_parent().remove_ball()
		queue_free()


func _integrate_forces(state):
	# Ensure the ball maintains constant speed
	if state.linear_velocity.length() < speed:
		state.linear_velocity = state.linear_velocity.normalized() * speed

	# Check if the ball goes out of bounds
	if position.x < -10 or position.x > 580 or position.y > 1300:
		get_parent().remove_ball()
		queue_free()

func reflect_velocity_with_limit(normal):
	var reflection = linear_velocity.bounce(normal)
	var min_angle = deg_to_rad(15)  # Minimum allowed angle deviation

	# Ensure the reflection is not too vertical or horizontal
	if abs(reflection.angle_to(Vector2.RIGHT)) < min_angle:
		reflection = reflection.rotated(sign(reflection.y) * min_angle)
	
	# Add a slight downward offset to avoid horizontal loops
	reflection += Vector2(0, 50)  # Push the ball downward slightly

	linear_velocity = reflection.normalized() * speed

func add_speed(boost_speed):
	speed += boost_speed
