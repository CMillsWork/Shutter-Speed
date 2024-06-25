extends AnimatedSprite2D

enum state {
	DEFAULT,
	READY,
	CAPTURING
}

const rect_size = Vector2(96,64)
var current_state = state.DEFAULT
var crop_zone:Rect2 = Rect2(Vector2.ZERO, rect_size)

# Called when the node enters the scene tree for the first time.
func _ready():
	play("default")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("ready_camera"):
		play("holding_camera")
		current_state = state.READY
		print_debug('camera ready')
	
	if Input.is_action_just_released("ready_camera"):
		current_state = state.DEFAULT
		play("default")
	
	if current_state == state.READY && Input.is_action_just_pressed("take_picture"):
		current_state = state.CAPTURING
		play("take_picture")
		print_debug("taking picture")
		
		var viewport_texture : ViewportTexture = get_viewport().get_texture()
		var photo : Image = viewport_texture.get_image()
		
		#photo = Image.create_from_data(96, 64, false, photo.get_format(), photo.get_data())
		photo.blit_rect(photo, crop_zone, Vector2.ZERO)
		
		get_parent().add_photo_to_album(photo)


func _on_animation_finished():
	if current_state == state.CAPTURING:
		current_state = state.READY
		play('holding_camera')


func _input(event):
	if event is InputEventMouseMotion:
		# Update our TextureRect's position to the event position.
		# An additional adjustment is made to put the rectangle at the  
		# center of the cursor, instead of at the top-left corner.
		var rect_position = -0.5 * rect_size + event.position
		crop_zone.position = rect_position
