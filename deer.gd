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

var current_state : int = state.IDLE

var nearby_food : Array = []
var nearby_water : Array = []
var nearby_social : Array = []
var nearby_shelter : Array = []

@onready var wander_timer : Timer = $WanderTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	food = randi_range(750, 1000)
	water = randi_range(750, 1000)
	social = randi_range(750, 1000)
	shelter = randi_range(750, 1000)
	fear = randi_range(750, 1000)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if fear > 0:
		fear -= 1 * delta
	
	if food > 0:
		food -= randi_range(0,1) * delta
	
	if water > 0:
		water -= randi_range(0,1) * delta
	
	if shelter > 0:
		shelter -= randi_range(0,1) * delta
	
	if social > 0:
		social -= randi_range(0,1) * delta
	
	var lowest_stat = min(food, water, social, shelter)
	
	if current_state == state.IDLE:
		# check statuses
		if food == lowest_stat && lowest_stat < 500:
			print_debug('Lowest stat is food')
			hunger_behavior()
		elif water == lowest_stat && lowest_stat < 500:
			print_debug('Lowest stat is water')
			thirst_behavior()
		elif social == lowest_stat && lowest_stat < 500:
			print_debug('Lowest stat is social')
			social_behavior()
		elif shelter == lowest_stat && lowest_stat < 500:
			print_debug('Lowest stat is shelter')
			sheltering_behavior()
		else:
			var current_pos = global_position
			var search_target = Vector2(current_pos.x + randf_range(-25,25), current_pos.y + randf_range(-25,25))
			$NavigationAgent2D.target_position = search_target
			while !$NavigationAgent2D.is_target_reachable:
				search_target = Vector2(current_pos.x + randf_range(-25,25), current_pos.y + randf_range(-25,25))
				$NavigationAgent2D.target_position = search_target

	elif lowest_stat + fear >= 1000:
		frightened_behavior()
	
	if current_state == state.WANDER:
		if wander_timer.is_stopped():
			wander_timer.start(3)
	
	$NavigationAgent2D.get_next_path_position()
	
	if $NavigationAgent2D.is_navigation_finished:
		match current_state:
			state.HUNGRY:
				current_state = state.EATING
			state.THIRSTY:
				current_state = state.DRINKING
			state.TIRED:
				current_state = state.RESTING
	
	var direction = $NavigationAgent2D.get_next_path_position() - global_position
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()


func wander_behavior():
	var current_pos = global_position
	var search_target = Vector2(current_pos.x + randf_range(-50,50), current_pos.y + randf_range(-50,50))
	#print_debug('wandering to: ', search_target)
	$NavigationAgent2D.set_target_position(search_target)
	while !$NavigationAgent2D.is_target_reachable:
		search_target = Vector2(current_pos.x + randf_range(-50,50), current_pos.y + randf_range(-50,50))
		$NavigationAgent2D.set_target_position(search_target)
	
	if wander_timer.is_stopped():
		wander_timer.start(3)


func hunger_behavior():
	# if we know where food is, go to the food and start eating
	# otherwise, wander
	var random = randi_range(0,50)
	if food + random >= 100:
		current_state = state.IDLE
		return 
	if nearby_food.size() > 0:
		current_state = state.HUNGRY
		var food_size = nearby_food.size()
		var rand_target = randi_range(0,food_size-1)
		var target : Node2D = nearby_food[rand_target]
		$NavigationAgent2D.set_target_position(target.global_position)
		$NavigationAgent2D.get_next_path_position()
	else:
		print_debug('no nearby_food, wandering')
		current_state = state.WANDER


func thirst_behavior():
	# if we know where water is, go to the water 
	# otherwise, wander
	var random = randi_range(0,50)
	if water + random >= 100:
		current_state = state.IDLE
		return
		
	if nearby_water.size() > 0:
		current_state = state.THIRSTY
		var water_size = nearby_water.size()
		var rand_target = randi_range(0,water_size-1)
		var target : Node2D = nearby_water[rand_target]
		$NavigationAgent2D.set_target_position(target.global_position)
		$NavigationAgent2D.get_next_path_position()
	else:
		print_debug('no nearby_water, wandering')
		current_state = state.WANDER


func social_behavior():
	var random = randi_range(0,50)
	if social + random >= 100:
		current_state = state.IDLE
		return
		
	if nearby_social.size() > 0:
		current_state = state.LONELY
		var social_size = nearby_social.size()
		var rand_target = randi_range(0,social_size-1)
		var target : Node2D = nearby_social[rand_target]
		$NavigationAgent2D.set_target_position(target.global_position)
		$NavigationAgent2D.get_next_path_position()
	else:
		print_debug('no nearby_social, wandering')
		current_state = state.WANDER


func sheltering_behavior():
	var random = randi_range(0,50)
	if shelter + random >= 100:
		current_state = state.IDLE
		return
	
	if nearby_shelter.size() > 0:
		current_state = state.TIRED
		var shelter_size = nearby_shelter.size()
		var rand_target = randi_range(0,shelter_size-1)
		var target : Node2D = nearby_shelter[rand_target]
		$NavigationAgent2D.set_target_position(target.global_position)
		$NavigationAgent2D.get_next_path_position()
	else:
		print_debug('no nearby_shelter, wandering')
		current_state = state.WANDER

func frightened_behavior():
	pass

func _on_wander_timer_timeout():
	wander_behavior()
