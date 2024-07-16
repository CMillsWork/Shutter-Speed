extends "res://creature.gd"

# tracks contact with player
# menace > 100: stalk
# menace > 250: get closer
# menace > 500: attack
var menace : int = 0
var player_in_range : bool = false

func _ready():
	speed = 250


func _process(_delta):
	# if the player is not close, add menace
	if !player_in_range:
		add_menace(1 * _delta)
	else:
		add_menace(-1 * _delta)
	
	if menace > 500:
		current_state = state.HUNGRY
	
	super(_delta)


func hunger_behavior():
	var nearby_food = get_tree().get_nodes_in_group('Deer')
	nearby_food.append_array(get_tree().get_nodes_in_group('Player'))
	
	if nearby_food.size() > 0:
		var food_size = nearby_food.size()
		var rand_target = randi_range(0,food_size-1)
		var target : Node2D = nearby_food[rand_target]
		$NavigationAgent2D.set_target_position(target.global_position)
		$NavigationAgent2D.target_desired_distance = 0
		$NavigationAgent2D.get_next_path_position()
	else:
		print_debug('no nearby_food, wandering')
		current_state = state.WANDER
		current_task = Callable(self,"wander_behavior")
		tasks.append(state.HUNGRY)


func _on_interaction_range_area_entered(area):
	if area.is_in_group('Deer') || area.is_in_group('Player'):
		if current_state == state.HUNGRY:
			current_state = state.EATING
			current_task = Callable(self, "eating_behavior")
			area.get_parent().die()
	if area.is_in_group('Water'):
		if current_state == state.THIRSTY:
			current_state = state.DRINKING
			current_task = Callable(self, "drinking_behavior")
	if area.is_in_group('Shelter'):
		if current_state == state.TIRED:
			current_state = state.RESTING
			current_task = Callable(self, "drinking_behavior")


func add_menace(amount):
	if menace + amount < 0:
		menace = 0
	
	elif menace > amount > 1000:
		menace = 1000
	
	else:
		menace += amount

func _on_menace_range_area_entered(area):
	player_in_range = true


func picture_taken():
	menace -= 500
