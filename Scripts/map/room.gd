extends Node2D


# references to the door visuals
@onready var door_sound = $door_sound
@onready var top_door = $top_door
@onready var bottom_door = $bottom_door
@onready var left_door = $left_door
@onready var right_door = $right_door
@onready var key_checks = $key_checks

# references to the adjacent rooms
var top_room = null
var bottom_room = null
var left_room = null
var right_room = null
@onready var label = $Label

# defines a random number generator
var rng = RandomNumberGenerator.new()
var spawn_x = 322/2
var spawn_y = 164/2


# sets up the number of enemies
var enemies_spawned = []
var can_play_sound = false
# saves the room's data type
var room_type = RoomData.room_types.no_type


func _ready():
	## set if the doors are locked, etc
	#top_door.lock()
	pass

func refresh_type_text():
	label.text = "Type: " + str(room_type)

# when a body enters the player_detector
func _on_player_detector_body_entered(body):
	# if the body is the player
	if body is Player:
		# emit the signal room_entered
		Events.room_entered.emit(self)
		RoomData.current_room = self
		
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

func populate_room():
	if room_type == RoomData.room_types.starting:
		if get_tree().current_scene.name == "Floor1":
			var instance = RoomData.TUTORIAL.instantiate()
			instance.global_position = Vector2(0,226)
			get_tree().current_scene.add_child(instance)
	elif room_type == RoomData.room_types.random_item:
		print(name)
		var amount_of_items = rng.randi_range(0, 10)
		if amount_of_items == 0:
			print("no items spawned")
		else:
			var instance = RoomData.RANDOM_ITEM_SPAWNER.instantiate()
			add_child(instance)
			var vec_x = rng.randi_range(-spawn_x + 50, spawn_x-50)
			var pos_or_neg = rng.randi_range(-1, 1)
			vec_x = pos_or_neg * vec_x
			## y direction
			var vec_y = rng.randi_range(-spawn_y + 50, spawn_y-50)
			pos_or_neg = rng.randi_range(-1, 1)
			vec_y = pos_or_neg * vec_y
			var spawn_vector = Vector2(vec_x, vec_y)
			instance.position = spawn_vector
	elif room_type == RoomData.room_types.locked_item:
		pass
	elif room_type == RoomData.room_types.chest:
		var vec_x = rng.randi_range(-spawn_x + 40, spawn_x-40)
		var pos_or_neg = rng.randi_range(-1, 1)
		vec_x = pos_or_neg * vec_x
		## y direction
		var vec_y = rng.randi_range(-spawn_y + 40, spawn_y-40)
		pos_or_neg = rng.randi_range(-1, 1)
		vec_y = pos_or_neg * vec_y
		var instance = RoomData.ITEM_CHEST.instantiate()
		instance.position = Vector2(global_position.x + vec_x, global_position.y + vec_y)
		get_tree().current_scene.add_child(instance)
	elif room_type == RoomData.room_types.monster:
		pass
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
			var vec_x = rng.randi_range(-spawn_x + 70, spawn_x-70)
			var pos_or_neg = rng.randi_range(-1, 1)
			vec_x = pos_or_neg * vec_x
			## y direction
			var vec_y = rng.randi_range(-spawn_y + 60, spawn_y-60)
			pos_or_neg = rng.randi_range(-1, 1)
			vec_y = pos_or_neg * vec_y
			spawn_vector = Vector2(vec_x, vec_y)
		
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
			var vec_x = rng.randi_range(-spawn_x + 70, spawn_x-70)
			var pos_or_neg = rng.randi_range(-1, 1)
			vec_x = pos_or_neg * vec_x
			## y direction
			var vec_y = rng.randi_range(-spawn_y + 60, spawn_y-60)
			pos_or_neg = rng.randi_range(-1, 1)
			vec_y = pos_or_neg * vec_y
			spawn_vector = Vector2(vec_x, vec_y)
		
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
			trap_door.position = Vector2(-135, 0)
		elif left_door != null:
			trap_door.position = Vector2(135, 0)
		
		var amount_of_items = rng.randi_range(1, 2)
		for i in range(amount_of_items):
			var instance = RoomData.RANDOM_ITEM_SPAWNER.instantiate()
			add_child(instance)
			var vec_x = rng.randi_range(-spawn_x + 50, spawn_x-50)
			var pos_or_neg = rng.randi_range(-1, 1)
			vec_x = pos_or_neg * vec_x
			## y direction
			var vec_y = rng.randi_range(-spawn_y + 50, spawn_y-50)
			pos_or_neg = rng.randi_range(-1, 1)
			vec_y = pos_or_neg * vec_y
			var spawn_vector = Vector2(vec_x, vec_y)
			for item in items:
				if spawn_vector.distance_to(item.position) < 20:
					spawn_vector = Vector2(-item.position.x, -item.position.y)
			instance.position = spawn_vector
			items += [instance]
