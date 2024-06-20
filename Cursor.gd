extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()
	
	if Input.is_action_pressed("ready_camera"):
		if Input.is_action_just_pressed("take_picture"):
			print_debug('taking picture')
			play("take_picture")
		else:
			play("holding_camera")
			
	else:
		print_debug('default cursor')
		play("default")
