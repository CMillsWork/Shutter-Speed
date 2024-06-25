extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var index = get_index()
	var photo = get_parent().get_parent().photo_album[index]
	if photo is Image:
			var tex = TextureRect.new()
			tex.texture = photo
			$PhotoImage.texture = tex
