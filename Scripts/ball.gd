extends RigidBody2D

var speed:int = 1000
var shoot_direction = Vector2()

func _ready() -> void:
	shoot_direction = get_parent().show_direction()
	apply_central_impulse(shoot_direction)

func _on_body_entered(body):
	#print("Body entered: ", body.name)
	if body.is_in_group("brick"):
		#print("Brick detected in group")
		body.take_life()
	if body.is_in_group("bottom"):
		get_parent().remove_ball()
		queue_free()

func _integrate_forces(state):
	if state.linear_velocity.length() < speed:
		state.linear_velocity = state.linear_velocity.normalized()*speed
	var ball_safe_zone = self.position
	if ball_safe_zone.x < -10 or ball_safe_zone.x > 600 or ball_safe_zone.y < -10 or ball_safe_zone.y > 1080 :
		get_parent().remove_ball()
		queue_free()

func add_speed(boost_speed):
	speed += boost_speed
