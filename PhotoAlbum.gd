extends Control

var photo_album : Array = []
@onready var frame_factory = preload("res://photo_frame.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event.is_action_pressed("show_album"):
		if !get_tree().paused:
			visible = true
			get_tree().paused = true
		else:
			visible = false
			get_tree().paused = false


func add_photo(photo : Image):
	photo_album.append(photo)
	var new_photo = frame_factory.instantiate()
	$AlbumGrid.add_child(new_photo)


func _on_back_button_pressed():
	print_debug('back pressed')
	visible = false
	get_tree().paused = false
