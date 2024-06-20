extends CharacterBody2D


const SPEED = 3000.0

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
