extends AnimatedSprite2D

enum state {
	DEFAULT,
	READY,
	CAPTURING
}

const rect_size = Vector2(96,64)
var current_state = state.DEFAULT
var crop_zone:Rect2 = Rect2(Vector2.ZERO, rect_size)

@onready var subView : SubViewportContainer = $SubViewportContainer

# tags for creatures captured in area when photo taken
var contains_deer : bool 	= false
var contains_rabbit : bool 	= false
var contains_bird : bool 	= false
var contains_player : bool	= false
var contains_thing : bool	= false

# Called when the node enters the scene tree for the first time.
func _ready():
	play("default")
	#subView.texture = get_viewport().get_texture()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("ready_camera"):
		play("holding_camera")
		current_state = state.READY
	
	if Input.is_action_just_released("ready_camera"):
		current_state = state.DEFAULT
		play("default")
	
	if current_state == state.READY && Input.is_action_just_pressed("take_picture"):
		current_state = state.CAPTURING
		play("take_picture")
		
		$SubViewportContainer/SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		visible = false
		await RenderingServer.frame_pre_draw
		await RenderingServer.frame_post_draw
		var photo : Image = get_viewport().get_texture().get_image()
		var rectangle : Rect2i
		rectangle.position = Vector2i($PhotoBegin.global_position + get_canvas_transform().origin)
		rectangle.end = Vector2i($PhotoEnd.global_position + get_canvas_transform().origin)
		print_debug('global position, end = ', rectangle.position, ', ', rectangle.end)
		print_debug('mouse position = ', get_canvas_transform().origin)
		photo.blit_rect(photo, rectangle, get_viewport_rect().position)
		photo.crop(96,64)
		var texture : ImageTexture = ImageTexture.create_from_image(photo)
		
		$SubViewportContainer/SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await RenderingServer.frame_pre_draw
		await RenderingServer.frame_post_draw
		
		visible = true
		
		var array_subjects = [contains_deer, contains_rabbit, contains_bird, contains_player, contains_thing]
		
		get_parent().add_photo_to_album(texture, array_subjects)


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


func _on_photo_rectangle_body_entered(body):
	if body.is_in_group('Deer'):
		contains_deer = true
	if body.is_in_group('Rabbit'):
		contains_rabbit = true
	if body.is_in_group('Bird'):
		contains_bird = true
	if body.is_in_group('Player'):
		contains_player = true
	if body.is_in_group('Thing'):
		contains_thing = true


func _on_photo_rectangle_body_exited(body):
	if body.is_in_group('Deer'):
		contains_deer = false
	if body.is_in_group('Rabbit'):
		contains_rabbit = false
	if body.is_in_group('Bird'):
		contains_bird = false
	if body.is_in_group('Player'):
		contains_player = false
	if body.is_in_group('Thing'):
		contains_thing = false
