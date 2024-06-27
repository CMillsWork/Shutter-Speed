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
	help_text += 'Contains: '
	var other_subjects : bool = false
	
	#contains_deer 
	if array_subjects[0]:
		help_text += 'Deer'
		other_subjects = true
	# contains_rabbit
	if array_subjects[1]:
		if other_subjects:
			help_text += ', '
		help_text += 'Rabbit'
		other_subjects = true
	# contains_bird
	if array_subjects[2]:
		if other_subjects:
			help_text += ', '
		help_text += 'Bird'
		other_subjects = true
	# contains_player
	if array_subjects[3]:
		if other_subjects:
			help_text += ', '
		help_text += 'Player'
		other_subjects = true
	# contains_thing
	if array_subjects[4]:
		if other_subjects:
			help_text += ', '
		help_text += 'something terrible'
		other_subjects = true
	
	tooltip_text = help_text
