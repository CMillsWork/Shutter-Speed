extends CharacterBody2D


enum state {
	GROUND,
	WATER,
	BRUSH
}

const SPEED = 4500.0

var current_state

func _ready():
	current_state = state.GROUND


func _process(delta):
	
	velocity = Vector2(0,0)
	
	if(Input.is_action_pressed("move_left")):
		velocity.x = -1 * SPEED * delta
	
	if(Input.is_action_pressed("move_right")):
		velocity.x = 1 * SPEED * delta
	
	if(Input.is_action_pressed("move_up")):
		velocity.y = -1 * SPEED * delta
	
	if(Input.is_action_pressed("move_down")):
		velocity.y = 1 * SPEED * delta
	
	move_and_slide()
