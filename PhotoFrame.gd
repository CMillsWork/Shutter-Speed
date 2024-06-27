extends TextureRect

# tags for creatures captured in area when photo taken
var contains_deer : bool 	= false
var contains_rabbit : bool 	= false
var contains_bird : bool 	= false
var contains_player : bool	= false
var contains_thing : bool	= false

var help_text : String = ''

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = get_index()
	var photo = get_parent().get_parent().photo_album[index]
	if photo is ImageTexture:
		var photoImage : Sprite2D = $PhotoImage
		photoImage.texture = photo

func add_subjects(array_subjects):
	
	
	contains_deer = array_subjects[0]
	contains_rabbit = array_subjects[1]
	contains_bird = array_subjects[2]
	contains_player = array_subjects[3]
	contains_thing = array_subjects[4]
