extends StaticBody2D
@onready var label: Label = $Label

@export var life = 5

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	label.text = str(life)

func take_life():
	life -= 1
	#print("Brick hit! Remaining life:", life)
	if life <= 0:
		#print("Brick destroyed")
		queue_free()
