extends Sprite2D

var rotating = false  # Track if the cannon should rotate
var rotation_offset = deg_to_rad(90)  # Adjust this offset based on your sprite's default orientation

func _input(event):
	# Detect if the left mouse button is pressed or released
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			rotating = event.pressed  # True on press, false on release

func _process(delta):
	if rotating:
		rotate_toward_mouse()

func rotate_toward_mouse():
	# Get the global position of the mouse
	var mouse_position = get_global_mouse_position()
	var cannon_position = global_position

	# Calculate the angle between the cannon and the mouse
	var angle_to_mouse = (mouse_position - cannon_position).angle()

	# Apply the rotation with the offset
	rotation = angle_to_mouse + rotation_offset
