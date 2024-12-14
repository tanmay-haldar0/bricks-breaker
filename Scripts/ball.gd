extends RigidBody2D

# Variables
var speed: int = 1000
var shoot_direction = Vector2()
var first_ball_triggered: bool = false
var return_speed: float = 500  # Speed at which the ball returns to the cannon
var cannon_position: Vector2
var is_returning: bool = false  # Flag to check if the ball is returning

# Called when the node is added to the scene
func _ready() -> void:
	# Get the shoot direction from the parent (cannon)
	shoot_direction = get_parent().show_direction()
	shoot_direction += Vector2(randf_range(-10, 10), randf_range(-30, -10))  # Small random offset
	
	# Normalize and apply the shoot direction
	shoot_direction = shoot_direction.normalized() * speed
	apply_central_impulse(shoot_direction)

	# Get the cannon position from the parent
	cannon_position = get_parent().cannon.position

# Called every frame
func _process(delta):
	# Update cannon position
	cannon_position = get_parent().cannon.position

	# Check if the ball is close to the bottom and hasn't triggered the cannon position update
	if position.y >= 1190 and not get_parent().first_ball_triggered:
		get_parent().adjust_canon_position(position.x)  # Update cannon position immediately
		get_parent().first_ball_triggered = true  # Ensure this only happens once
	
	# Check if the ball is out of bounds
	if position.x < -10 or position.x > 600 or position.y < -2 or position.y > 1300:
		queue_free()
		get_parent().remove_ball()  # Remove the ball if out of bounds
	
	# Ensure the ball maintains constant speed
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if linear_velocity.length() < speed:
		linear_velocity = linear_velocity.normalized() * speed
		
# Function to return the ball to the cannon
func return_to_cannon():
	if not is_returning:
		is_returning = true  # Set the flag to indicate the ball is returning
		# Create a tween to animate the ball returning to the cannon
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", cannon_position, 0.5)  # Target property, final value, duration
		tween.set_trans(Tween.TRANS_CUBIC)  # Set transition type
		tween.set_ease(Tween.EASE_IN_OUT)  # Set easing type
		tween.tween_callback(self.queue_free)
		get_parent().remove_ball()

# Called when the tween animation is completed
func _on_tween_completed(tween):
	# Check if all balls have returned to the cannon
	get_parent().check_all_balls_returned()  # Call a function in the parent to check

# Called when the ball collides with another body
func _on_body_entered(body):
	if body.is_in_group("brick"):
		body.take_life()  # Call a method on the brick to take a life
		#reflect_velocity_with_limit((position - body.position).normalized())  # Reflect the ball's velocity
	
	if body.is_in_group("bottom"):
		return_to_cannon()
		
		  # Animate back to cannon instead of removing

# Function to reflect the ball's velocity with a limit on the angle
func reflect_velocity_with_limit(normal):
	var reflection = linear_velocity.bounce(normal)
	var min_angle = deg_to_rad(15)  # Minimum allowed angle deviation

	# Ensure the reflection is not too vertical or horizontal
	if abs(reflection.angle_to(Vector2.RIGHT)) < min_angle:
		reflection = reflection.rotated(min_angle * sign(reflection.y))  # Adjust the angle to meet the minimum requirement
	linear_velocity = reflection.normalized() * speed  # Set the new velocity while maintaining speed

func add_speed(boost_speed):
	speed += boost_speed
