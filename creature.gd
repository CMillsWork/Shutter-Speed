extends CharacterBody2D

# 0 = bad, 1000 = good
var food	: int = 0
var water	: int = 0
var social	: int = 0
var shelter	: int = 0

# 0 is good, 1000 is bad. Math was easier in my head for that
var fear	: int = 0

var speed = 100
var accel = 7

var tasks : Array = []

enum state {
	IDLE,
	HUNGRY,
	THIRSTY,
	LONELY,
	TIRED,
	FRIGHTENED,
	EATING,
	DRINKING,
	RESTING,
	WANDER
}

var current_state : int = state.WANDER
var current_task : Callable = func foo():{}

@onready var behavior_timer : Timer = $BehaviorTimer
var wander_range : int = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	food = randi_range(750, 1000)
	water = randi_range(750, 1000)
	social = randi_range(750, 1000)
	shelter = randi_range(750, 1000)
	fear = randi_range(0, 250)
	
	wander_behavior()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if fear > 0 && current_state != state.FRIGHTENED:
		fear -= 1 * delta
	
	if food > 0:
		food -= randi_range(0,1) * delta
	
	if water > 0:
		water -= randi_range(0,1) * delta
	
	if shelter > 0:
		shelter -= randi_range(0,1) * delta
	
	if social > 0:
		social -= randi_range(0,1) * delta

	
	if current_state == state.WANDER:
		if behavior_timer.is_stopped():
			behavior_timer.start(3)
			current_task = Callable(self, "wander_behavior")
	
	if food <= 500 && !tasks.has(state.HUNGRY):
		tasks.append(state.HUNGRY)
	
	if water <= 500 && !tasks.has(state.THIRSTY):
		tasks.append(state.THIRSTY)
	
	#if social <= 500 && !tasks.has(state.LONELY):
	#	tasks.append(state.LONELY)
	
	#if shelter <= 500 && !tasks.has(state.TIRED):
	#	tasks.append(state.TIRED)
	
	$NavigationAgent2D.get_next_path_position()

	# running away takes precedence
	if fear >= 500 && !tasks.has(state.FRIGHTENED):
		current_state = state.FRIGHTENED
		frightened_behavior()
	
	elif $NavigationAgent2D.is_navigation_finished:
		match current_state:
			state.HUNGRY:
				current_state = state.EATING
				print_debug('destination reached for EATING')
			state.THIRSTY:
				current_state = state.DRINKING
				print_debug('destination reached for DRINKING')
			state.TIRED:
				current_state = state.RESTING
				print_debug('destination reached for RESTING')
	
	var direction = $NavigationAgent2D.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()


func _on_behavior_timer_timeout():
	print_debug('timer ran out')
	# check needs, change tasks as needed
	var next_task = current_state
	 
	if tasks.size() > 0:
		next_task = tasks.pick_random()
	
	if next_task != state.WANDER:
		print_debug('current task is ', next_task)
		tasks.erase(next_task)
		
		match next_task:
			state.HUNGRY:
				print_debug('Changing task to HUNGRY')
				current_task = Callable(self, "hunger_behavior")
			state.THIRSTY:
				print_debug('Changing task to THIRSTY')
				current_task = Callable(self, "thirst_behavior")
			state.FRIGHTENED:
				print_debug('Changing task to FRIGHTENED')
				current_task = Callable(self, "frightened_behavior")
			
	current_task.call()


func wander_behavior():
	var current_pos = global_position
	var search_target = Vector2(current_pos.x + randf_range(-wander_range,wander_range), current_pos.y + randf_range(-wander_range,wander_range))
	#print_debug('wandering to: ', search_target)
	$NavigationAgent2D.set_target_position(search_target)
	$NavigationAgent2D.target_desired_distance = 0
	while !$NavigationAgent2D.is_target_reachable:
		print_debug('looking for new wandering target')
		search_target = Vector2(current_pos.x + randf_range(-wander_range,wander_range), current_pos.y + randf_range(-wander_range,wander_range))
		$NavigationAgent2D.set_target_position(search_target)
	
	if behavior_timer.is_stopped():
		var deviation = randf_range(-0.5, 0.5)
		print_debug('starting timer with time of ', 3+ deviation)
		behavior_timer.start(3 + deviation)


func hunger_behavior():
	var nearby_food = get_tree().get_nodes_in_group('FOOD')
	
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


func thirst_behavior():
	# if we know where water is, go to the water 
	# otherwise, wander
	var nearby_water = get_tree().get_nodes_in_group('WATER')
	
	if nearby_water.size() > 0:
		var water_size = nearby_water.size()
		var rand_target = randi_range(0,water_size-1)
		var target : Node2D = nearby_water[rand_target]
		$NavigationAgent2D.set_target_position(target.global_position)
		$NavigationAgent2D.target_desired_distance = 0
		$NavigationAgent2D.get_next_path_position()
	else:
		print_debug('no nearby_water, wandering')
		current_state = state.WANDER
		current_task = Callable(self,"wander_behavior")
		tasks.append(state.THIRSTY)


func social_behavior():		
	var nearby_social = get_tree().get_nodes_in_group(get_groups()[0])
	
	if nearby_social.size() > 0:
		current_state = state.LONELY
		var social_size = nearby_social.size()
		var rand_target = randi_range(0,social_size-1)
		var target : Node2D = nearby_social[rand_target]
		$NavigationAgent2D.set_target_position(target.global_position)
		$NavigationAgent2D.target_desired_distance = 0
		$NavigationAgent2D.get_next_path_position()
	else:
		print_debug('no nearby_social, wandering')
		current_state = state.WANDER
		current_task = Callable(self, "wander_behavior")
		tasks.append(state.LONELY)


func sheltering_behavior():
	var nearby_shelter = get_tree().get_nodes_in_group('SHELTER')
	
	if nearby_shelter.size() > 0:
		var shelter_size = nearby_shelter.size()
		var rand_target = randi_range(0,shelter_size-1)
		var target : Node2D = nearby_shelter[rand_target]
		$NavigationAgent2D.set_target_position(target.global_position)
		$NavigationAgent2D.target_desired_distance = 0
		$NavigationAgent2D.get_next_path_position()
	else:
		print_debug('no nearby_shelter, wandering')
		current_state = state.WANDER

func frightened_behavior():
	var predators = get_tree().get_nodes_in_group('Predator')
	
	if predators.size() > 0:
		var nearest : CharacterBody2D = predators[0]
		var distance_to_nearest = global_position.distance_to(nearest.global_position)
		
		for next_predator : CharacterBody2D in predators:
			if global_position.distance_to(next_predator.global_position) < distance_to_nearest:
				nearest = next_predator
				distance_to_nearest = global_position.distance_to(nearest.global_position)
				
		$NavigationAgent2D.set_target_position(nearest.global_position)
		$NavigationAgent2D.target_desired_distance = 500
		$NavigationAgent2D.get_next_path_position()


func _on_interaction_range_area_entered(area):
	if area.is_in_group('Food'):
		if current_state == state.HUNGRY:
			current_state = state.EATING
			current_task = Callable(self, "eating_behavior")
	if area.is_in_group('Water'):
		if current_state == state.THIRSTY:
			current_state = state.DRINKING
			current_task = Callable(self, "drinking_behavior")
	if area.is_in_group('Shelter'):
		if current_state == state.TIRED:
			current_state = state.RESTING
			current_task = Callable(self, "drinking_behavior")
