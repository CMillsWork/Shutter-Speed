extends Node2D

@onready var album_grid = %PhotoAlbum

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_photo_to_album(photo : Image):
	album_grid.add_photo(photo)


func get_player():
	return $Player

