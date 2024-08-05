extends Node2D


# references to the door visuals
@onready var door_sound = $door_sound
@onready var top_door = $top_door
@onready var bottom_door = $bottom_door
@onready var left_door = $left_door
@onready var right_door = $right_door
@onready var key_checks = $key_checks
@onready var boss_icons = $boss_icons
@onready var crystal_boss_icons = $crystal_boss_icons

@export var room_door_type = RoomData.door_type.four_doors

# references to the adjacent rooms
var top_room = null
var bottom_room = null
var left_room = null
var right_room = null
@onready var label = $Label

var unlocked = false
var room_boss_cleared = false

# defines a random number generator
var rng = RandomNumberGenerator.new()
# spawns in room size based on the enemy detected and the center of the room
var spawn_x = 322/2
var spawn_y = 164/2
# monster spawn amounts
var minimum_monster_spawns = 2
var maximum_monster_spawns = 5

# sets up the number of enemies
var enemies_spawned = []
var can_play_sound = false
# saves the room's data type
@export var room_type = RoomData.room_types.no_type


func _ready():
	label.hide()

func refresh_type_text():
	label.text = "Type: " + str(room_type)

# when a body enters the player_detector
func _on_player_detector_body_entered(body):
	# if the body is the player
	if body is Player:
		# emit the signal room_entered
		Events.room_entered.emit(self)
		RoomData.current_room = self
		
		if room_type == RoomData.room_types.locked_item && unlocked == false:
			unlock_adjacent_rooms()
		
		# if there are no enemies in the room
		if enemies_spawned.size() == 0:
			# disable the doors
			disable_all_doors()
			# lets the player know they entered a room
			Events.player.room_entered(self)
			# check the lock status when the player enters the room and there are no enemies
			if Events.player.has_keys():
				key_checks.locks_changed(true)
			else:
				key_checks.locks_changed(false)
			
			boss_icon_logic(true)
		# if there are enemies in the room
		elif enemies_spawned.size() > 0:
			# enable the doors
			close_all_doors()
			# wake_up each enemy
			for enemy in enemies_spawned:
				enemy.wake_up()
			# check the lock status when the player enters the room
			key_checks.locks_changed(false)
			# lets the player know the room has enemies
			Events.player.room_has_enemies()
			
			boss_icon_logic(false)

# when an body enters
func _on_enemy_detector_body_entered(body):
	# if the body is an enemy
	if room_type != RoomData.room_types.starting:
		if body is Enemy:
			# adds an enemy to the count and a refernce to the enemy
			enemies_spawned = enemies_spawned + [body]

# when a body exits the enemy detector
func _on_enemy_detector_body_exited(body):
	# if the body is an enemy
	if room_type != RoomData.room_types.starting:
		# if the body is an enemy
		if body is Enemy:
			if enemies_spawned[enemies_spawned.find(body)].dying:
				# remove a enemy from the count
				enemies_spawned.remove_at(enemies_spawned.find(body))
				# if all enemies are gone, disable the doors
				if enemies_spawned.size() == 0:
					open_all_doors()
					# check the lock status when the player enters the room and there are no enemies
					if Events.player.has_keys():
						key_checks.locks_changed(true)
					else:
						key_checks.locks_changed(false)
					
					if room_type == RoomData.room_types.boss || room_type == RoomData.room_types.crystal_boss:
						room_boss_cleared = true
					boss_icon_logic(true)

# closes all doors
func close_all_doors():
	if top_door != null:
		top_door.close_door()
	if bottom_door != null:
		bottom_door.close_door()
	if left_door != null:
		left_door.close_door()
	if right_door != null:
		right_door.close_door()
	# plays the door sound
	door_sound.play()

# opens all doors
func open_all_doors():
	if top_door != null:
		top_door.open_door()
	if bottom_door != null:
		bottom_door.open_door()
	if left_door != null:
		left_door.open_door()
	if right_door != null:
		right_door.open_door()
	# plays the door sound
	door_sound.play()
	
	Events.player.room_cleared()

# disables all doors
func disable_all_doors():
	if top_door != null:
		top_door.disable_door()
	if bottom_door != null:
		bottom_door.disable_door()
	if left_door != null:
		left_door.disable_door()
	if right_door != null:
		right_door.disable_door()

# unlock a specific door
func unlock_door(door):
	if door == top_door:
		if top_door != null:
			top_door.open_door()
	elif door == bottom_door:
		if bottom_door != null:
			bottom_door.open_door()
	elif door == left_door:
		if left_door != null:
			left_door.open_door()
	elif door == right_door:
		if right_door != null:
			right_door.open_door()
	# plays the door sound
	door_sound.play()

# if there are enemies in the room, return true
func is_enemies():
	if enemies_spawned.size() > 0:
		return true
	else:
		return false

func get_enemies_in_room():
	return enemies_spawned

# when the player obtains a key, reset the locks icons
func player_obtained_keys():
	key_checks.locks_changed(true)

func enemy_spawned_in_room():
	# enable the doors
	close_all_doors()
	# check the lock status when the player enters the room
	key_checks.locks_changed(false)
	Events.player.room_has_enemies()
	boss_icon_logic(false)

func cleared():
	enemies_spawned = []
	open_all_doors()

func get_connected_rooms():
	return [top_room, bottom_room, left_room, right_room]

func set_connected_room_right(room):
	if room != null:
		right_room = room

func set_connected_room_left(room):
	if room != null:
		left_room = room

func set_connected_room_top(room):
	if room != null:
		top_room = room

func set_connected_room_bottom(room):
	if room != null:
		bottom_room = room

func has_door_top():
	if top_door != null:
		return true
	else:
		return false

func has_door_bottom():
	if bottom_door != null:
		return true
	else:
		return false

func has_door_right():
	if right_door != null:
		return true
	else:
		return false

func has_door_left():
	if left_door != null:
		return true
	else:
		return false

func has_connection_top():
	if top_room != null:
		return true
	else:
		return false

func has_connection_bottom():
	if bottom_room != null:
		return true
	else:
		return false

func has_connection_left():
	if left_room != null:
		return true
	else:
		return false

func has_connection_right():
	if right_room != null:
		return true
	else:
		return false

func set_room_type(type : RoomData.room_types):
	room_type = type

func get_room_type():
	return room_type 

func get_door_type():
	return room_door_type 

func populate_room():
	if room_type == RoomData.room_types.starting:
		if get_tree().current_scene.name == "Floor1":
			var instance = RoomData.TUTORIAL.instantiate()
			instance.global_position = Vector2(0,226)
			get_tree().current_scene.add_child(instance)
	elif room_type == RoomData.room_types.random_item:
		var amount_of_items = rng.randi_range(0, 10)
		if amount_of_items == 0:
			var amount_of_obstacles = rng.randi_range(0, 3)
			var obstacles = []
			for i in range(amount_of_obstacles):
				var random_obstacle = RoomData.obstacles[rng.randi_range(0, RoomData.obstacles.size()-1)]
				var obstacle = random_obstacle.instantiate()
				get_tree().current_scene.add_child(obstacle)
				var spawn_vector
				var matches_position = true
				while matches_position:
					matches_position = false
					spawn_vector = get_random_position(40)
					for obst in obstacles:
						if obst.global_position.distance_to(spawn_vector + global_position) <= 60:
							matches_position = true
				obstacle.global_position = spawn_vector + global_position
				obstacles += [obstacle]
		else:
			var instance = RoomData.RANDOM_ITEM_SPAWNER.instantiate()
			add_child(instance)
			var spawn_vector = get_random_position(50)
			instance.position = spawn_vector
	elif room_type == RoomData.room_types.locked_item:
		var instance = RoomData.RANDOM_ITEM_SPAWNER.instantiate()
		add_child(instance)
		var spawn_vector = get_random_position(50)
		instance.position = spawn_vector
		
		# set locks on adjacent rooms
		lock_adjacent_rooms()
	elif room_type == RoomData.room_types.chest:
		var vect = get_random_position(40)
		var instance = RoomData.ITEM_CHEST.instantiate()
		instance.position = Vector2(global_position.x + vect.x, global_position.y + vect.y)
		get_tree().current_scene.add_child(instance)
	elif room_type == RoomData.room_types.monster:
		var amount_of_obstacles = rng.randi_range(0, 2)
		#var amount_of_obstacles = 0
		var obstacles = []
		for i in range(amount_of_obstacles):
			var random_obstacle = RoomData.obstacles[rng.randi_range(0, RoomData.obstacles.size()-1)]
			var obstacle = random_obstacle.instantiate()
			get_tree().current_scene.add_child(obstacle)
			var spawn_vector
			var matches_position = true
			while matches_position:
				matches_position = false
				spawn_vector = get_random_position(40)
				for obst in obstacles:
					if obst.global_position.distance_to(spawn_vector + global_position) <= 60:
						matches_position = true
			obstacle.global_position = spawn_vector + global_position
			obstacles += [obstacle]
		
		var amount_of_mobs = rng.randi_range(minimum_monster_spawns, maximum_monster_spawns)
		#var amount_of_mobs = 1
		var possible_mobs
		if get_tree().current_scene.name == "Floor1":
			possible_mobs = RoomData.floor_1_mobs
		elif get_tree().current_scene.name == "Floor2":
			possible_mobs = RoomData.floor_2_mobs
		elif get_tree().current_scene.name == "Floor3":
			possible_mobs = RoomData.floor_3_mobs
		elif get_tree().current_scene.name == "Floor4":
			possible_mobs = RoomData.floor_4_mobs
		
		var spawned_mobs = []
		for i in range(amount_of_mobs):
			var random_mob = possible_mobs[rng.randi_range(0, possible_mobs.size()-1)]
			var instance = random_mob.instantiate()
			get_tree().current_scene.add_child(instance)
			var spawn_vector
			var matches_position = true
			var iterations = 0
			while matches_position && iterations <= 30:
				matches_position = false
				spawn_vector = get_random_position(55)
				for mob in spawned_mobs:
					if mob.global_position.distance_to(spawn_vector + global_position) <= 40:
						matches_position = true
				for obst in obstacles:
					if obst.global_position.distance_to(spawn_vector + global_position) <= 40:
						matches_position = true
				iterations += 1
			if iterations < 30:
				instance.global_position = spawn_vector + global_position
				var collision = instance.move_and_collide(Vector2(0.0,0.0))
				# if there is a collision at the location, despawn the mob
				if collision != null:
					instance.despawn()
				if instance != null:
					spawned_mobs += [instance]
			else:
				instance.despawn()
	elif room_type == RoomData.room_types.crystal_boss:
		var spawn_vector = Vector2(0, 0)
		if top_door != null &&  bottom_door != null &&  right_door != null &&  left_door != null:
			spawn_vector = Vector2(0, 0)
		elif top_door == null:
			spawn_vector = Vector2(0, -30)
		elif bottom_door == null:
			spawn_vector = Vector2(0, 50)
		elif right_door == null:
			spawn_vector = Vector2(110, 20)
		elif left_door == null:
			spawn_vector = Vector2(-110, 20)
		else:
			spawn_vector = get_random_position(60)
		
		var instance
		if get_tree().current_scene.name == "Floor1":
			instance = RoomData.SAPPHIRE_PEGASUS.instantiate()
		elif get_tree().current_scene.name == "Floor2":
			instance = RoomData.QUARTZ_BEHEMOTH.instantiate()
		elif get_tree().current_scene.name == "Floor3":
			instance = RoomData.EMERALD_SKELETON.instantiate()
		elif get_tree().current_scene.name == "Floor4":
			instance = RoomData.ONYX_DEMON.instantiate()
		
		if instance != null:
			get_tree().current_scene.add_child(instance)
			instance.global_position = position + spawn_vector
			
			# set icons on adjacent rooms
	elif room_type == RoomData.room_types.boss:
		var spawn_vector = Vector2(0, 0)
		if top_door != null &&  bottom_door != null &&  right_door != null &&  left_door != null:
			spawn_vector = Vector2(0, 0)
		elif top_door == null:
			spawn_vector = Vector2(0, -30)
		elif bottom_door == null:
			spawn_vector = Vector2(0, 50)
		elif right_door == null:
			spawn_vector = Vector2(110, 20)
		elif left_door == null:
			spawn_vector = Vector2(-110, 20)
		else:
			spawn_vector = get_random_position(60)
		
		var instance
		if get_tree().current_scene.name == "Floor1":
			instance = RoomData.GELATINOUS_CUBE.instantiate()
		elif get_tree().current_scene.name == "Floor2":
			instance = RoomData.FORGOTTEN_GOLEM.instantiate()
		elif get_tree().current_scene.name == "Floor3":
			instance = RoomData.LICH.instantiate()
		elif get_tree().current_scene.name == "Floor4":
			instance = RoomData.LOST_KNIGHT.instantiate()
		
		if instance != null:
			get_tree().current_scene.add_child(instance)
			instance.global_position = position + spawn_vector
			
			# set icons on adjacent rooms
	elif room_type == RoomData.room_types.ending:
		var items = []
		
		var floor_text = RoomData.FLOOR_TEXT.instantiate()
		get_tree().current_scene.add_child(floor_text)
		floor_text.global_position = Vector2(global_position.x, global_position.y+30)
		
		var trap_door = RoomData.TRAPDOOR.instantiate()
		floor_text.add_child(trap_door)
		
		if top_door != null:
			trap_door.position = Vector2(0, 58) - Vector2(0, 30)
		elif bottom_door != null:
			trap_door.position = Vector2(0, -58) - Vector2(0, 30)
		elif right_door != null:
			trap_door.position = Vector2(-135, 0)- Vector2(0, 30)
		elif left_door != null:
			trap_door.position = Vector2(135, 0)- Vector2(0, 30)
		
		items += [trap_door]
		
		var amount_of_items = rng.randi_range(1, 2)
		for i in range(amount_of_items):
			var instance
			if i == 1:
				instance = RoomData.RANDOM_HEALTH_SPAWNER.instantiate()
			else:
				instance = RoomData.RANDOM_ITEM_SPAWNER.instantiate()
			add_child(instance)
			var spawn_vector
			var matches_position = true
			while matches_position:
				matches_position = false
				spawn_vector = get_random_position(50)
				for item in items:
					if spawn_vector.distance_to(item.position) < 20:
						matches_position = true
			if instance != null:
				instance.position = spawn_vector
				items += [instance]
	elif room_type == RoomData.room_types.no_type:
		var amount_of_obstacles = rng.randi_range(0, 3)
		var obstacles = []
		for i in range(amount_of_obstacles):
			var random_obstacle = RoomData.obstacles[rng.randi_range(0, RoomData.obstacles.size()-1)]
			var obstacle = random_obstacle.instantiate()
			get_tree().current_scene.add_child(obstacle)
			var spawn_vector
			var matches_position = true
			while matches_position:
				matches_position = false
				spawn_vector = get_random_position(40)
				for obst in obstacles:
					if obst.global_position.distance_to(spawn_vector + global_position) <= 60:
						matches_position = true
			obstacle.global_position = spawn_vector + global_position
			obstacles += [obstacle]

func lock_adjacent_rooms():
	if top_room != null:
		top_room.lock_bottom_door()
		top_room.refresh_key_icons()
	if bottom_room != null:
		bottom_room.lock_top_door()
		bottom_room.refresh_key_icons()
	if right_room != null:
		right_room.lock_left_door()
		right_room.refresh_key_icons()
	if left_room != null:
		left_room.lock_right_door()
		left_room.refresh_key_icons()

func get_top_door():
	return top_door

func get_bottom_door():
	return bottom_door

func get_left_door():
	return left_door

func get_right_door():
	return right_door

func lock_top_door():
	top_door.locked = true
	top_door.lock()

func lock_bottom_door():
	bottom_door.locked = true
	bottom_door.lock()

func lock_left_door():
	left_door.locked = true
	left_door.lock()

func lock_right_door():
	right_door.locked = true
	right_door.lock()

func unlock_top_door():
	top_door.locked = false
	top_door.unlock()

func unlock_bottom_door():
	bottom_door.locked = false
	bottom_door.unlock()

func unlock_left_door():
	left_door.locked = false
	left_door.unlock()

func unlock_right_door():
	right_door.locked = false
	right_door.unlock()

func refresh_key_icons():
	if Events.player.has_keys():
		key_checks.locks_changed(true)
	else:
		key_checks.locks_changed(false)

func unlock_adjacent_rooms():
	if top_room != null:
		top_room.unlock_bottom_door()
		top_room.refresh_key_icons()
	if bottom_room != null:
		bottom_room.unlock_top_door()
		bottom_room.refresh_key_icons()
	if right_room != null:
		right_room.unlock_left_door()
		right_room.refresh_key_icons()
	if left_room != null:
		left_room.unlock_right_door()
		left_room.refresh_key_icons()
	unlocked = true

func boss_icon_logic(sprites_pulsing : bool):
	if top_room != null:
		if top_room.room_type == RoomData.room_types.boss:
			if sprites_pulsing && !top_room.room_boss_cleared:
				boss_icons.show_sprite_top()
			else:
				boss_icons.inactive_sprite_top()
		else:
			boss_icons.hide_sprite_top()
		
		if top_room.room_type == RoomData.room_types.crystal_boss:
			if sprites_pulsing && !top_room.room_boss_cleared:
				crystal_boss_icons.show_sprite_top()
			else:
				crystal_boss_icons.inactive_sprite_top()
		else:
			crystal_boss_icons.hide_sprite_top()
	
	if bottom_room != null:
		if bottom_room.room_type == RoomData.room_types.boss:
			if sprites_pulsing && !bottom_room.room_boss_cleared:
				boss_icons.show_sprite_bottom()
			else:
				boss_icons.inactive_sprite_bottom()
		else:
			boss_icons.hide_sprite_bottom()
		
		if bottom_room.room_type == RoomData.room_types.crystal_boss:
			if sprites_pulsing && !bottom_room.room_boss_cleared:
				crystal_boss_icons.show_sprite_bottom()
			else:
				crystal_boss_icons.inactive_sprite_bottom()
		else:
			crystal_boss_icons.hide_sprite_bottom()
	
	if right_room != null:
		if right_room.room_type == RoomData.room_types.boss:
			if sprites_pulsing && !right_room.room_boss_cleared:
				boss_icons.show_sprite_right()
			else:
				boss_icons.inactive_sprite_right()
		else:
			boss_icons.hide_sprite_right()
		
		if right_room.room_type == RoomData.room_types.crystal_boss:
			if sprites_pulsing && !right_room.room_boss_cleared:
				crystal_boss_icons.show_sprite_right()
			else:
				crystal_boss_icons.inactive_sprite_right()
		else:
			crystal_boss_icons.hide_sprite_right()
	
	if left_room != null:
		if left_room.room_type == RoomData.room_types.boss:
			if sprites_pulsing && !left_room.room_boss_cleared:
				boss_icons.show_sprite_left()
			else:
				boss_icons.inactive_sprite_left()
		else:
			boss_icons.hide_sprite_left()
		
		if left_room.room_type == RoomData.room_types.crystal_boss:
			if sprites_pulsing && !left_room.room_boss_cleared:
				crystal_boss_icons.show_sprite_left()
			else:
				crystal_boss_icons.inactive_sprite_left()
		else:
			crystal_boss_icons.hide_sprite_left()

func adjacent_rooms_boss_icon_logic():
	if top_room != null:
		top_room.boss_icon_logic(false)
	if bottom_room != null:
		bottom_room.boss_icon_logic(false)
	if left_room != null:
		left_room.boss_icon_logic(false)
	if right_room != null:
		right_room.boss_icon_logic(false)

func get_random_position(offset : int):
	# direction
	var vec_x = rng.randi_range(-spawn_x + offset, spawn_x-offset)
	var pos_or_neg = rng.randi_range(-10, 10)
	if pos_or_neg > 0:
		pos_or_neg = 1
	elif pos_or_neg < 0:
		pos_or_neg = -1
	vec_x = pos_or_neg * vec_x
	## y direction
	var vec_y = rng.randi_range(-spawn_y + offset, spawn_y-offset)
	pos_or_neg = rng.randi_range(-10, 10)
	if pos_or_neg > 0:
		pos_or_neg = 1
	elif pos_or_neg < 0:
		pos_or_neg = -1
	vec_y = pos_or_neg * vec_y
	return Vector2(vec_x, vec_y)
