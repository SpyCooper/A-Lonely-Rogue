extends Node2D

# sets up a direction enum
enum direction
{
	top,
	bottom,
	left,
	right,
}

# makes an array of all the directions
var directions = [direction.top, direction.bottom, direction.left, direction.right]

# 1 door rooms
const _1_DOOR_ROOM_DOWN = preload("res://Scenes/map/rooms/1_door_room_down.tscn")
const _1_DOOR_ROOM_LEFT = preload("res://Scenes/map/rooms/1_door_room_left.tscn")
const _1_DOOR_ROOM_RIGHT = preload("res://Scenes/map/rooms/1_door_room_right.tscn")
const _1_DOOR_ROOM_UP = preload("res://Scenes/map/rooms/1_door_room_up.tscn")
# 2 door rooms
const _2_DOOR_DOWN_LEFT = preload("res://Scenes/map/rooms/2_door_down_left.tscn")
const _2_DOOR_DOWN_RIGHT = preload("res://Scenes/map/rooms/2_door_down_right.tscn")
const _2_DOOR_LEFT_RIGHT = preload("res://Scenes/map/rooms/2_door_left_right.tscn")
const _2_DOOR_ROOM_UP_LEFT = preload("res://Scenes/map/rooms/2_door_room_up_left.tscn")
const _2_DOOR_ROOM_UP_RIGHT = preload("res://Scenes/map/rooms/2_door_room_up_right.tscn")
const _2_DOOR_UP_DOWN = preload("res://Scenes/map/rooms/2_door_up_down.tscn")
# 3 door rooms
const _3_DOOR_ROOM_NO_DOWN = preload("res://Scenes/map/rooms/3_door_room_no_down.tscn")
const _3_DOOR_ROOM_NO_LEFT = preload("res://Scenes/map/rooms/3_door_room_no_left.tscn")
const _3_DOOR_ROOM_NO_RIGHT = preload("res://Scenes/map/rooms/3_door_room_no_right.tscn")
const _3_DOOR_ROOM_NO_UP = preload("res://Scenes/map/rooms/3_door_room_no_up.tscn")
# 4 door room
const _4_DOOR_ROOM = preload("res://Scenes/map/rooms/4_door_room.tscn")

# list of rooms that can connect to the top doorway
var rooms_that_can_connect_to_top = [
	_2_DOOR_DOWN_LEFT,
	_2_DOOR_DOWN_RIGHT,
	_2_DOOR_UP_DOWN,
	_3_DOOR_ROOM_NO_LEFT,
	_3_DOOR_ROOM_NO_RIGHT,
	_3_DOOR_ROOM_NO_UP,
	_4_DOOR_ROOM,
	_1_DOOR_ROOM_DOWN,
]

# list of rooms that can connect to the bottom doorway
var rooms_that_can_connect_to_bottom = [
	_2_DOOR_ROOM_UP_LEFT,
	_2_DOOR_ROOM_UP_RIGHT,
	_2_DOOR_UP_DOWN,
	_3_DOOR_ROOM_NO_LEFT,
	_3_DOOR_ROOM_NO_RIGHT,
	_3_DOOR_ROOM_NO_DOWN,
	_4_DOOR_ROOM,
	_1_DOOR_ROOM_UP,
]

# list of rooms that can connect to the right doorway
var rooms_that_can_connect_to_right = [
	_2_DOOR_DOWN_LEFT,
	_2_DOOR_LEFT_RIGHT,
	_2_DOOR_ROOM_UP_LEFT,
	_3_DOOR_ROOM_NO_DOWN,
	_3_DOOR_ROOM_NO_RIGHT,
	_3_DOOR_ROOM_NO_UP,
	_4_DOOR_ROOM,
	_1_DOOR_ROOM_LEFT,
]

# list of rooms that can connect to the left doorway
var rooms_that_can_connect_to_left = [
	_2_DOOR_DOWN_RIGHT,
	_2_DOOR_LEFT_RIGHT,
	_2_DOOR_ROOM_UP_RIGHT,
	_3_DOOR_ROOM_NO_DOWN,
	_3_DOOR_ROOM_NO_LEFT,
	_3_DOOR_ROOM_NO_UP,
	_4_DOOR_ROOM,
	_1_DOOR_ROOM_RIGHT,
]

# list of all rooms
var all_rooms = [
	_1_DOOR_ROOM_DOWN,
	_1_DOOR_ROOM_LEFT,
	_1_DOOR_ROOM_RIGHT,
	_1_DOOR_ROOM_UP,
	_2_DOOR_DOWN_LEFT,
	_2_DOOR_DOWN_RIGHT,
	_2_DOOR_LEFT_RIGHT,
	_2_DOOR_ROOM_UP_LEFT,
	_2_DOOR_ROOM_UP_RIGHT,
	_2_DOOR_UP_DOWN,
	_3_DOOR_ROOM_NO_DOWN,
	_3_DOOR_ROOM_NO_LEFT,
	_3_DOOR_ROOM_NO_RIGHT,
	_3_DOOR_ROOM_NO_UP,
	_4_DOOR_ROOM,
]

# list of all spawnable room types
var spawnable_room_types = [
	RoomData.room_types.random_item,
	RoomData.room_types.locked_item,
	RoomData.room_types.chest,
	RoomData.room_types.crystal_boss,
	RoomData.room_types.boss,
	RoomData.room_types.monster,
]

# list of room types that can be directly next to spawn
var spawnable_room_types_near_spawn = [
	RoomData.room_types.random_item,
	RoomData.room_types.locked_item,
	RoomData.room_types.chest,
	RoomData.room_types.monster,
]

# list of room types that can limitless
var unlimited_room_types = [
	RoomData.room_types.monster,
	RoomData.room_types.no_type,
]

# values for item rooms
var minimum_item_rooms = 1
var maximum_item_rooms = 2
var current_item_rooms = 0
# values for chest rooms
var minimum_chest_rooms = 1
var maximum_chest_rooms = 2
var current_chest_rooms = 0
# values for locked rooms
var minimum_locked_rooms = 1
var maximum_locked_rooms = 2
var current_locked_rooms = 0
# values for monster rooms
var minimum_monster_rooms = 4
var current_monster_rooms = 0

# defines a random number generator
var rng = RandomNumberGenerator.new()

# list of all rooms
var rooms = []
# bools for rooms that can only have 1 type
var boss_room_spawned = false
var ending_room_spawned = false
var crystal_boss_room_spawned = false
# starting room
var starting_room
# bool for if rooms need to close
var close_rooms = false
# bool for if minimum requirements are met
var minimum_requirements_met = false

# when the ranomizer is loaded
func _ready():
	# when the room_entered signal is sent
	Events.room_entered.connect(func(room):
		# check if minimum requirements are met
		are_minimum_requirements_met()
		# if minimum requirments are met
		if minimum_requirements_met:
			# start closing rooms
			close_rooms = true
		# spawn adjacent rooms next to the current room
		spawn_adjacent_rooms(room)
	)

# when start is called by floor 1
func start():
	# spawn the starting room
	spawn_starting_room()

# checks if minimum requirements are met
func are_minimum_requirements_met():
	# if minimum requirements are not already met
	if !minimum_requirements_met:
		# check if the minimum values for each room type are met
		var item_room_met = false
		var monster_room_met = false
		var locked_rooms_met = false
		var chest_rooms_met = false
		if current_item_rooms >= minimum_item_rooms:
			item_room_met = true
		if current_monster_rooms >= minimum_monster_rooms:
			monster_room_met = true
		if current_locked_rooms >= minimum_locked_rooms:
			locked_rooms_met = true
		if current_chest_rooms >= minimum_chest_rooms:
			chest_rooms_met = true
		# if all the minimum values are met, return true
		if item_room_met && monster_room_met && locked_rooms_met && chest_rooms_met && crystal_boss_room_spawned && boss_room_spawned && ending_room_spawned:
			minimum_requirements_met = true
		# if all the minim values are not met, return false
		else:
			minimum_requirements_met = false

# returns a random spawnable room type
func random_room_type():
	var type
	# if there are spawnable room types
	if spawnable_room_types.size() != 0:
		# choose a random spawnable room type
		type = spawnable_room_types[rng.randi_range(0,spawnable_room_types.size()-1)]
	# if a type was chooses
	if type != null:
		# return that type
		return type
	# if a type wasn't choosen, return a random unlimited room type
	else:
		return unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]

# marks the room type as spawned
func spawned_room_type(type : RoomData.room_types):
	# if the type was a random item room type
	if type == RoomData.room_types.random_item:
		# increase that room type's counter
		current_item_rooms += 1
		# if the room type counter has hit the max, remove it from the spawnable_room_types list
		if current_item_rooms == maximum_item_rooms:
			spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.random_item))
	# if the type was a chest room type
	elif type == RoomData.room_types.chest:
		# increase that room type's counter
		current_chest_rooms += 1
		# if the room type counter has hit the max, remove it from the spawnable_room_types list
		if current_chest_rooms == maximum_chest_rooms:
			spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.chest))
	# if the type was a locked item room type
	elif type == RoomData.room_types.locked_item:
		# increase that room type's counter
		current_locked_rooms += 1
		# if the room type counter has hit the max, remove it from the spawnable_room_types list
		if current_locked_rooms == maximum_locked_rooms:
			spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.locked_item))
	# if the type was a monster room type
	elif type == RoomData.room_types.monster:
		# increase that room type's counter
		current_monster_rooms += 1
	# if the type was a crystal boss room type
	elif type == RoomData.room_types.crystal_boss:
		# remove it from the spawnable_room_types list
		spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.crystal_boss))
		# mark the crystal boss room as spawned
		crystal_boss_room_spawned = true
	# if the type was a boss room type
	elif type == RoomData.room_types.boss:
		# remove it from the spawnable_room_types list
		spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.boss))
		# mark the boss room as spawned
		boss_room_spawned = true
	
	# if the spawnable room types size is 1 and the last type is monster, remove the monster type
	if spawnable_room_types.size() == 1 && spawnable_room_types[0] == RoomData.room_types.monster:
		spawnable_room_types.remove_at(0)

# returns a random room type that can be near spawn
func random_room_type_near_spawn():
	var type
	# if there are spawnable room type near spawn
	if spawnable_room_types_near_spawn.size() != 0:
		# choose a random spawnable room type near spawn
		type = spawnable_room_types_near_spawn[rng.randi_range(0,spawnable_room_types_near_spawn.size()-1)]
	# if a type was chooses
	if type != null:
		# return that type
		return type
	# if a type wasn't choosen, return a random unlimited room type
	else:
		return unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]

# spawns the starting room
func spawn_starting_room():
	# gets a random room from all rooms
	var random_starting_room = rng.randi_range(0,all_rooms.size()-1)
	# spawns in the random room at 0, 0
	starting_room = all_rooms[random_starting_room].instantiate()
	starting_room.global_position = Vector2(0, 0)
	get_tree().current_scene.add_child(starting_room)
	# sets the room type
	starting_room.set_room_type(RoomData.room_types.starting)
	# adds the starting room to the list of rooms
	rooms += [starting_room]
	# refreshes the room type (used for bug testing)
	starting_room.refresh_type_text()
	# populates the starting room
	starting_room.populate_room()

# spawns rooms adjacent to the current room
func spawn_adjacent_rooms(room):
	# gets the room's current connections
	var connected_rooms = room.get_connected_rooms()
	# defines which iteration the for loop is on (will always be 4)
	var iteration = 0
	# for each connected room in connected rooms
	for connected_room in connected_rooms:
		# define a new room and a room type
		var new_room
		var type
		# if the current room is spawn
		if room == starting_room:
			# get a random room type near spawn
			type = random_room_type_near_spawn()
		# if the current room is not spawn
		else:
			# get a random room type
			type = random_room_type()
		# mark if single door rooms can spawn based on if minimum requirements are met
		var can_spawn_single_door_room = false
		if minimum_requirements_met:
			can_spawn_single_door_room = true
		# iterate
		iteration += 1
		# if the connect room is nothing (meaning there is no connected room)
		if connected_room == null:
			## add a room to the top of the current room
			# iterations 1 = top connection
			if iteration == 1:
				# if there is a door to the rop and the room doesn not have a connect to the top
				if room.has_door_top() && !room.has_connection_top():
					# set the target room position to be above the current room
					var target_room_position = room.global_position + Vector2(0, -224)
					# if there is not a room already in that position
					if get_room_at_position(target_room_position) == null:
						# if the current room type is locked item, boss or crystal boss
						if type == RoomData.room_types.locked_item || type == RoomData.room_types.boss || type == RoomData.room_types.crystal_boss:
							# if the are no other empty doors on the floor
							if !check_for_other_empty_doors(target_room_position):
								# the type cannot be locked item, crystal boss, or boss
								# select an unlimited room type
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						# check for connections to where the new room is going to go
						var top_connection = get_connection_top(target_room_position)
						var left_connection = get_connection_left(target_room_position)
						var right_connection = get_connection_right(target_room_position)
						# if the new room needs to connect on all sides (down is implied)
						if top_connection != null && right_connection != null && left_connection != null:
							# if type is a boss, switch it to an unlimited room type
							if type == RoomData.room_types.boss:
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
							# spawn a 4 door room
							new_room = _4_DOOR_ROOM.instantiate()
						# if the new room needs to connect on the top and right sides (down is implied)
						elif top_connection != null && right_connection != null && left_connection == null:
							# if the rooms are closing, locked, or a crystal boss
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								# choose the smallest room possible
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							# if there is not a room to the left of the new room
							elif get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
								# get a room with more doorways
								new_room = _4_DOOR_ROOM.instantiate()
							# if there is a room the left of the new room
							else:
								# the type of the room cannot be a boss room
								if type == RoomData.room_types.boss:
									type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
								# get the room with the required amount of doorways for all connections
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
						# if the new room needs to connect on the top and left sides (down is implied)
						elif top_connection != null && right_connection == null && left_connection != null:
							# if the rooms are closing, locked, or a crystal boss
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								# choose the smallest room possible
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							# if there is not a room to the right of the new room
							elif get_room_at_position(target_room_position + Vector2(384, 0)) == null:
								# get a room with more doorways
								new_room = _4_DOOR_ROOM.instantiate()
							# if there is a room the right of the new room
							else:
								# the type of the room cannot be a boss room
								if type == RoomData.room_types.boss:
									type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
								# get the room with the required amount of doorways for all connections
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
						# if the new room needs to connect on the left and right sides (down is implied)
						elif top_connection == null && right_connection != null && left_connection != null:
							# if the rooms are closing, locked, or a crystal boss
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								# choose the smallest room possible
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							# if there is not a room to the top of the new room
							elif get_room_at_position(target_room_position + Vector2(0, -224)) == null:
								# get a room with more doorways
								new_room = _4_DOOR_ROOM.instantiate()
							# if there is a room the top of the new room
							else:
								# the type of the room cannot be a boss room
								if type == RoomData.room_types.boss:
									type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
								# get the room with the required amount of doorways for all connections
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
						# if the new room needs to connect on the top side (down is implied)
						elif top_connection != null && right_connection == null && left_connection == null:
							# if the rooms are closing, locked, or a crystal boss
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								# choose the smallest room possible
								new_room = _2_DOOR_UP_DOWN.instantiate()
							else:
								# checks if the room can have a left connection
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								# checks if the room can have a right connection
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								# if the room can have a left and right connection
								if can_have_left && can_have_right:
									# get any room that can fit in that location with a new door
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								# if the room can have a left but not a right connection
								elif can_have_left && !can_have_right:
									# get the room that can have an empty doorway
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								# if the room can have a right but not a left connection
								elif !can_have_left && can_have_right:
									# get the room that can have an empty doorway
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								# if the room cannot have either a left or right connection
								else:
									# the type cannot be a boss room
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									# get the room type that fits those connection
									new_room = _2_DOOR_UP_DOWN.instantiate()
						# if the new room needs to connect on the right side (down is implied)
						elif top_connection == null && right_connection != null && left_connection == null:
							# if the rooms are closing, locked, or a crystal boss
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								# choose the smallest room possible
								new_room = _2_DOOR_DOWN_RIGHT.instantiate()
							else:
								# checks if the room can have a left connection
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								# checks if the room can have a top connection
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								# if the room can have a left and a top connection
								if can_have_left && can_have_top:
									# get any room that can fit in that location with a new door
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								# if the room can have a left but not a top connection
								elif can_have_left && !can_have_top:
									# get the room that can have an empty doorway
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								# if the room can have a top but not a left connection
								elif !can_have_left && can_have_top:
									# get the room that can have an empty doorway
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								# if the room cannot have either a left and a top connection
								else:
									# the type cannot be a boss room
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									# spawn a room that fits those connections
									new_room = _2_DOOR_DOWN_RIGHT.instantiate()
						# if the new room needs to connect on the left side (down is implied)
						elif top_connection == null && right_connection == null && left_connection != null:
							# if the rooms are closing, locked, or a crystal boss
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								# choose the smallest room possible
								new_room = _2_DOOR_DOWN_LEFT.instantiate()
							else:
								# checks if the room can have a right connection
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								# checks if the room can have a top connection
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								# if the room can have a right and a top connection
								if can_have_right && can_have_top:
									# get any room that can fit in that location with a new door
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								# if the room can have a right but not a top connection
								elif can_have_right && !can_have_top:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								# if the room can have a top but not a right connection
								elif !can_have_right && can_have_top:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								# if the room cannot have either a right and a top connection
								else:
									# the room type cannot be a boss room
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									# spawn a room that fits those connections
									new_room = _2_DOOR_DOWN_LEFT.instantiate()
						# if the new room doesn't need to connect to any other sides (down is implied)
						else:
							# if the rooms are closing, locked, or a crystal boss
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								# choose the smallest room possible
								new_room = _1_DOOR_ROOM_DOWN.instantiate()
							else:
								# checks if the room can have a left connection
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								# checks if the room can have a right connection
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								# checks if the room can have a top connection
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								# if the room type can have all 3 connections
								if can_have_left && can_have_right && can_have_top:
									# get a random room that can connect to the top
									var random_number = rng.randi_range(0,rooms_that_can_connect_to_top.size()-1)
									# if the random room is a single door
									if random_number == rooms_that_can_connect_to_top.size()-1:
										# check if single doors can spawn
										if !can_spawn_single_door_room:
											# if single doors cannot spawn, get another random room
											random_number = rng.randi_range(0,rooms_that_can_connect_to_top.size()-2)
									# spawn the random room that can connect to the top of another room
									var random_room = rooms_that_can_connect_to_top[random_number]
									new_room = random_room.instantiate()
								# if the new room can have a left, a right, but not a top room
								elif can_have_left && can_have_right && !can_have_top:
									# get a random room that has an empty doorway
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								# if the new room can have a left, a top, but not a right room
								elif can_have_left && !can_have_right && can_have_top:
									# get a random room that has an empty doorway
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								# if the new room can have a top, a right, but not a left room
								elif !can_have_left && can_have_right && can_have_top:
									# get a random room that has an empty doorway
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								# if the new room can have a left, but not a right or a top room
								elif can_have_left && !can_have_right && !can_have_top:
									# spawns a room that has an empty doorway
									new_room = _2_DOOR_DOWN_LEFT.instantiate()
								# if the new room can have a top, but not a right or a left room
								elif !can_have_left && !can_have_right && can_have_top:
									# spawns a room that has an empty doorway
									new_room = _2_DOOR_UP_DOWN.instantiate()
								# if the new room can have a right, but not a left or a top room
								elif !can_have_left && can_have_right && !can_have_top:
									# spawns a room that has an empty doorway
									new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								# if the new room cannot have any connections
								elif !can_have_left && !can_have_right && !can_have_top:
									# the type cannot be a boss room
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									# the room has to be 1 door room
									new_room = _1_DOOR_ROOM_DOWN.instantiate()
						# spawns the new room
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = target_room_position
						# sets the top connection for the new room
						new_room.set_connected_room_top(top_connection)
						if top_connection != null:
							top_connection.set_connected_room_bottom(new_room)
						# sets the bottom connection for the new room
						new_room.set_connected_room_bottom(room)
						# sets the left connection for the new room
						new_room.set_connected_room_left(left_connection)
						if left_connection != null:
							left_connection.set_connected_room_right(new_room)
						# sets the right connection for the new room
						new_room.set_connected_room_right(right_connection)
						if right_connection != null:
							right_connection.set_connected_room_left(new_room)
						# adds the new room to the list of rooms
						rooms += [new_room]
						# sets the current room's top connection to the new room
						room.set_connected_room_top(new_room)
						# if the type is boss room and the ending room cannot spawn
						if type == RoomData.room_types.boss && check_if_ending_room_can_spawn(new_room) == false:
							# the type cannot be a boss toom
							type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						# sets the type for the room
						new_room.set_room_type(type)
						# refreshed the floor text of the room (used for testing
						new_room.refresh_type_text()
			## add a room to the bottom of the current room
			# iterations 2 = bottom connection
			elif iteration == 2:
				if room.has_door_bottom() && !room.has_connection_bottom():
					var target_room_position = room.global_position + Vector2(0, 224)
					
					if get_room_at_position(target_room_position) == null:
						
						if type == RoomData.room_types.locked_item || type == RoomData.room_types.boss || type == RoomData.room_types.crystal_boss:
							if !check_for_other_empty_doors(target_room_position):
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						var bottom_connection = get_connection_bottom(target_room_position)
						var left_connection = get_connection_left(target_room_position)
						var right_connection = get_connection_right(target_room_position)
						
						if bottom_connection != null && right_connection != null && left_connection != null:
							if type == RoomData.room_types.boss:
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
							new_room = _4_DOOR_ROOM.instantiate()
						elif bottom_connection != null && right_connection != null && left_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									new_room = _4_DOOR_ROOM.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
						elif bottom_connection != null && right_connection == null && left_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									new_room = _4_DOOR_ROOM.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
						elif bottom_connection == null && right_connection != null && left_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									new_room = _4_DOOR_ROOM.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
						elif bottom_connection != null && right_connection == null && left_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _2_DOOR_UP_DOWN.instantiate()
							else:
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								
								if can_have_left && can_have_right:
									# get any room
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								elif can_have_left && !can_have_right:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								elif !can_have_left && can_have_right:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _2_DOOR_UP_DOWN.instantiate()
						elif bottom_connection == null && right_connection != null && left_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
							else:
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								var can_have_bottom = false
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									can_have_bottom = true
								
								if can_have_left && can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								elif can_have_left && !can_have_bottom:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								elif !can_have_left && can_have_bottom:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
						elif bottom_connection == null && right_connection == null && left_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
							else:
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								var can_have_bottom = false
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									can_have_bottom = true
								
								if can_have_right && can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								elif can_have_right && !can_have_bottom:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								elif !can_have_right && can_have_bottom:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
						else:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _1_DOOR_ROOM_UP.instantiate()
							else:
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								var can_have_bottom = false
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									can_have_bottom = true
								
								if can_have_left && can_have_right && can_have_bottom:
									var random_number = rng.randi_range(0,rooms_that_can_connect_to_bottom.size()-1)
									if random_number == rooms_that_can_connect_to_bottom.size()-1:
										if !can_spawn_single_door_room:
											random_number = rng.randi_range(0,rooms_that_can_connect_to_bottom.size()-2)
									var random_room = rooms_that_can_connect_to_bottom[random_number]
									new_room = random_room.instantiate()
								elif can_have_left && can_have_right && !can_have_bottom:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif can_have_left && !can_have_right && can_have_bottom:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_UP_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif !can_have_left && can_have_right && can_have_bottom:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_UP_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif can_have_left && !can_have_right && !can_have_bottom:
									new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif !can_have_left && !can_have_right && can_have_bottom:
									new_room = _2_DOOR_UP_DOWN.instantiate()
								elif !can_have_left && can_have_right && !can_have_bottom:
									new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif !can_have_left && !can_have_right && !can_have_bottom:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _1_DOOR_ROOM_UP.instantiate()
							
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = target_room_position
						new_room.set_connected_room_top(room)
						new_room.set_connected_room_bottom(bottom_connection)
						if bottom_connection != null:
							bottom_connection.set_connected_room_top(new_room)
						new_room.set_connected_room_left(left_connection)
						if left_connection != null:
							left_connection.set_connected_room_right(new_room)
						new_room.set_connected_room_right(right_connection)
						if right_connection != null:
							right_connection.set_connected_room_left(new_room)
						rooms += [new_room]
						room.set_connected_room_bottom(new_room)
						
						if type == RoomData.room_types.boss &&  check_if_ending_room_can_spawn(new_room) == false:
							type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						new_room.set_room_type(type)
						new_room.refresh_type_text()
			# add a room to the left of the current room
			# iterations 3 = left connection
			elif iteration == 3:
				if room.has_door_left() && !room.has_connection_left():
					var target_room_position = room.global_position + Vector2(-384, 0)
					
					if get_room_at_position(target_room_position) == null:
						
						if type == RoomData.room_types.locked_item || type == RoomData.room_types.boss || type == RoomData.room_types.crystal_boss:
							if !check_for_other_empty_doors(target_room_position):
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						var top_connection = get_connection_top(target_room_position)
						var bottom_connection = get_connection_bottom(target_room_position)
						var left_connection = get_connection_left(target_room_position)
						
						if top_connection != null && bottom_connection != null && left_connection != null:
							if type == RoomData.room_types.boss:
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
							new_room = _4_DOOR_ROOM.instantiate()
						elif top_connection != null && bottom_connection != null && left_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									new_room = _4_DOOR_ROOM.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
						elif top_connection != null && bottom_connection == null && left_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									new_room = _4_DOOR_ROOM.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
						elif top_connection == null && bottom_connection != null && left_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									new_room = _4_DOOR_ROOM.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
						elif top_connection != null && bottom_connection == null && left_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
							else:
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								var can_have_bottom = false
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									can_have_bottom = true
								
								if can_have_left && can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								elif can_have_left && !can_have_bottom:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								elif !can_have_left && can_have_bottom:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
						elif top_connection == null && bottom_connection != null && left_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _2_DOOR_DOWN_RIGHT.instantiate()
							else:
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								
								if can_have_left && can_have_top:
									# get any room
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								elif can_have_left && !can_have_top:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								elif !can_have_left && can_have_top:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _2_DOOR_DOWN_RIGHT.instantiate()
						elif top_connection == null && bottom_connection == null && left_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _2_DOOR_LEFT_RIGHT.instantiate()
							else:
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								var can_have_bottom = false
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									can_have_bottom = true
								
								if can_have_bottom && can_have_top:
									# get any room
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								elif can_have_bottom && !can_have_top:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								elif !can_have_bottom && can_have_top:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _2_DOOR_LEFT_RIGHT.instantiate()
						else:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _1_DOOR_ROOM_RIGHT.instantiate()
							else:
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								var can_have_bottom = false
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									can_have_bottom = true
								
								if can_have_left && can_have_top && can_have_bottom:
									var random_number = rng.randi_range(0,rooms_that_can_connect_to_left.size()-1)
									if random_number == rooms_that_can_connect_to_left.size()-1:
										if !can_spawn_single_door_room:
											random_number = rng.randi_range(0,rooms_that_can_connect_to_left.size()-2)
									var random_room = rooms_that_can_connect_to_left[random_number]
									new_room = random_room.instantiate()
								elif can_have_left && can_have_top && !can_have_bottom:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif can_have_left && !can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif !can_have_left && can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif can_have_left && !can_have_top && !can_have_bottom:
									new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								elif !can_have_left && !can_have_top && can_have_bottom:
									new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif !can_have_left && can_have_top && !can_have_bottom:
									new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif !can_have_left && !can_have_top && !can_have_bottom:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _1_DOOR_ROOM_RIGHT.instantiate()
						
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = target_room_position
						new_room.set_connected_room_top(top_connection)
						if top_connection != null:
							top_connection.set_connected_room_bottom(new_room)
						new_room.set_connected_room_bottom(bottom_connection)
						if bottom_connection != null:
							bottom_connection.set_connected_room_top(new_room)
						new_room.set_connected_room_left(left_connection)
						if left_connection != null:
							left_connection.set_connected_room_right(new_room)
						new_room.set_connected_room_right(room)
						rooms += [new_room]
						room.set_connected_room_left(new_room)
						
						if type == RoomData.room_types.boss &&  check_if_ending_room_can_spawn(new_room) == false:
							type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						new_room.set_room_type(type)
						new_room.refresh_type_text()
			# add a room to the right of the current room
			# iterations 4 = right connection
			elif iteration == 4:
				if room.has_door_right() && !room.has_connection_right():
					var target_room_position = room.global_position + Vector2(384, 0)
					
					if get_room_at_position(target_room_position) == null:
						
						if type == RoomData.room_types.locked_item || type == RoomData.room_types.boss || type == RoomData.room_types.crystal_boss:
							if !check_for_other_empty_doors(target_room_position):
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						var top_connection = get_connection_top(target_room_position)
						var bottom_connection = get_connection_bottom(target_room_position)
						var right_connection = get_connection_right(target_room_position)
						
						if top_connection != null && bottom_connection != null && right_connection != null:
							if type == RoomData.room_types.boss:
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
							new_room = _4_DOOR_ROOM.instantiate()
						elif top_connection != null && bottom_connection != null && right_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									new_room = _4_DOOR_ROOM.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
						elif top_connection != null && bottom_connection == null && right_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									new_room = _4_DOOR_ROOM.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
						elif top_connection == null && bottom_connection != null && right_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									new_room = _4_DOOR_ROOM.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
						elif top_connection != null && bottom_connection == null && right_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
							else:
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								var can_have_bottom = false
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									can_have_bottom = true
								
								if can_have_right && can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								elif can_have_right && !can_have_bottom:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								elif !can_have_right && can_have_bottom:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
						elif top_connection == null && bottom_connection != null && right_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _2_DOOR_DOWN_LEFT.instantiate()
							else:
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								
								if can_have_right && can_have_top:
									# get any room
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								elif can_have_right && !can_have_top:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								elif !can_have_right && can_have_top:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _2_DOOR_DOWN_LEFT.instantiate()
						elif top_connection == null && bottom_connection == null && right_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _2_DOOR_LEFT_RIGHT.instantiate()
							else:
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								var can_have_bottom = false
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									can_have_bottom = true
								
								if can_have_bottom && can_have_top:
									# get any room
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								elif can_have_bottom && !can_have_top:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								elif !can_have_bottom && can_have_top:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								else:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _2_DOOR_LEFT_RIGHT.instantiate()
						else:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _1_DOOR_ROOM_LEFT.instantiate()
							else:
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								var can_have_bottom = false
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									can_have_bottom = true
								
								if can_have_right && can_have_top && can_have_bottom:
									var random_number = rng.randi_range(0,rooms_that_can_connect_to_right.size()-1)
									if random_number == rooms_that_can_connect_to_right.size()-1:
										if !can_spawn_single_door_room:
											random_number = rng.randi_range(0,rooms_that_can_connect_to_right.size()-2)
									var random_room = rooms_that_can_connect_to_right[random_number]
									new_room = random_room.instantiate()
								elif can_have_right && can_have_top && !can_have_bottom:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif can_have_right && !can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
								elif !can_have_right && can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
								elif can_have_right && !can_have_top && !can_have_bottom:
									new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								elif !can_have_right && !can_have_top && can_have_bottom:
									new_room = _2_DOOR_DOWN_LEFT.instantiate()
								elif !can_have_right && can_have_top && !can_have_bottom:
									new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif !can_have_right && !can_have_top && !can_have_bottom:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _1_DOOR_ROOM_LEFT.instantiate()
						
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = target_room_position
						new_room.set_connected_room_top(top_connection)
						if top_connection != null:
							top_connection.set_connected_room_bottom(new_room)
						new_room.set_connected_room_bottom(bottom_connection)
						if bottom_connection != null:
							bottom_connection.set_connected_room_top(new_room)
						new_room.set_connected_room_left(room)
						new_room.set_connected_room_right(right_connection)
						if right_connection != null:
							right_connection.set_connected_room_left(new_room)
						rooms += [new_room]
						room.set_connected_room_right(new_room)
						
						if type == RoomData.room_types.boss &&  check_if_ending_room_can_spawn(new_room) == false:
							type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						new_room.set_room_type(type)
						new_room.refresh_type_text()
			# if a new room spawned
			if new_room != null:
				# mark the type as having spawned
				spawned_room_type(type)
				# do the boss icon logic on the new room (icon cannot flash)
				new_room.boss_icon_logic(false)
				# if the room type was boss
				if type ==  RoomData.room_types.boss:
					# spawn the ending room
					spawn_ending_room(new_room)
				# populate the new room
				new_room.populate_room()

# spawns the ending room based on the boss room location
func spawn_ending_room(boss_room):
	# define a new room
	var new_room
	# get the ending room direction from the boss room
	var ending_room_direction = get_ending_room_spawn(boss_room)
	# if the ending room direction is top
	if ending_room_direction == direction.top:
		# set the ending room location
		var target_room_position = boss_room.global_position + Vector2(0, -224)
		# check if the there is a room at the location and that the boss room has a door to that location
		if get_room_at_position(target_room_position) == null && boss_room.has_door_top():
			# spawn the corresponding 1 door room at the position
			new_room = _1_DOOR_ROOM_DOWN.instantiate()
			get_tree().current_scene.add_child(new_room)
			new_room.global_position = target_room_position
			# set the connection for the boss room and the ending room
			new_room.set_connected_room_bottom(boss_room)
			boss_room.set_connected_room_top(new_room)
			# adds the new room to the list rooms
			rooms += [new_room]
			# sets the room type to ending
			new_room.set_room_type(RoomData.room_types.ending)
			# refreshes the floor text of the room (used for testing)
			new_room.refresh_type_text()
	# if the ending room direction is bottom
	elif ending_room_direction == direction.bottom:
		# set the ending room location
		var target_room_position = boss_room.global_position + Vector2(0, 224)
		# check if the there is a room at the location and that the boss room has a door to that location
		if get_room_at_position(target_room_position) == null && boss_room.has_door_bottom():
			# spawn the corresponding 1 door room at the position
			new_room = _1_DOOR_ROOM_UP.instantiate()
			get_tree().current_scene.add_child(new_room)
			new_room.global_position = target_room_position
			# set the connection for the boss room and the ending room
			new_room.set_connected_room_top(boss_room)
			boss_room.set_connected_room_bottom(new_room)
			# adds the new room to the list rooms
			rooms += [new_room]
			# sets the room type to ending
			new_room.set_room_type(RoomData.room_types.ending)
			# refreshes the floor text of the room (used for testing)
			new_room.refresh_type_text()
	# if the ending room direction is left
	elif ending_room_direction == direction.left:
		# set the ending room location
		var target_room_position = boss_room.global_position + Vector2(-384, 0)
		# check if the there is a room at the location and that the boss room has a door to that location
		if get_room_at_position(target_room_position) == null && boss_room.has_door_left():
			# spawn the corresponding 1 door room at the position
			new_room = _1_DOOR_ROOM_RIGHT.instantiate()
			get_tree().current_scene.add_child(new_room)
			new_room.global_position = target_room_position
			# set the connection for the boss room and the ending room
			new_room.set_connected_room_right(boss_room)
			boss_room.set_connected_room_left(new_room)
			# adds the new room to the list rooms
			rooms += [new_room]
			# sets the room type to ending
			new_room.set_room_type(RoomData.room_types.ending)
			# refreshes the floor text of the room (used for testing)
			new_room.refresh_type_text()
	# if the ending room direction is right
	elif ending_room_direction == direction.right:
		# set the ending room location
		var target_room_position = boss_room.global_position + Vector2(384, 0)
		# check if the there is a room at the location and that the boss room has a door to that location
		if get_room_at_position(target_room_position) == null && boss_room.has_door_right():
			# spawn the corresponding 1 door room at the position
			new_room = _1_DOOR_ROOM_LEFT.instantiate()
			get_tree().current_scene.add_child(new_room)
			new_room.global_position = target_room_position
			# set the connection for the boss room and the ending room
			new_room.set_connected_room_left(boss_room)
			boss_room.set_connected_room_right(new_room)
			# adds the new room to the list rooms
			rooms += [new_room]
			# sets the room type to ending
			new_room.set_room_type(RoomData.room_types.ending)
			# refreshes the floor text of the room (used for testing)
			new_room.refresh_type_text()
	# if a new room was spawned
	if new_room != null:
		# mark the ending room as spawned
		ending_room_spawned = true
		# populate the ending room
		new_room.populate_room()
	# if the ending room is not spawned
	else:
		# pass (was used for testing)
		pass

# checks if there are nother empty doors that do not point at the current position
func check_for_other_empty_doors(current_position : Vector2):
	# starts a count of other empty doors
	var number_of_empty_doorways = 0
	# for each room in rooms
	for room in rooms:
		# get the connected rooms
		var connected_rooms = room.get_connected_rooms()
		var iteration = 0
		# for each connected room
		for connected_room in connected_rooms:
			iteration += 1
			# if the room exists
			if connected_room == null:
				# the top of the current room
				if iteration == 1:
					# check if there is a doorwat that points at the position above the room
					if room.has_door_top() && !room.has_connection_top():
						var target_room_position = room.global_position + Vector2(0, -224)
						# if the current position is not the target position and there is no room at that position
						if current_position != target_room_position && get_room_at_position(target_room_position) == null:
							# increment the number of empty doorways
							number_of_empty_doorways += 1
				# bottom of the current room
				elif iteration == 2:
					# check if there is a doorwat that points at the below above the room
					if room.has_door_bottom() && !room.has_connection_bottom():
						var target_room_position = room.global_position + Vector2(0, 224)
						# if the current position is not the target position and there is no room at that position
						if current_position != target_room_position && get_room_at_position(target_room_position) == null:
							# increment the number of empty doorways
							number_of_empty_doorways += 1
				# left of the current room
				elif iteration == 3:
					# check if there is a doorwat that points at the position to the left the room
					if room.has_door_left() && !room.has_connection_left():
						var target_room_position = room.global_position + Vector2(-384, 0)
						# if the current position is not the target position and there is no room at that position
						if current_position != target_room_position && get_room_at_position(target_room_position) == null:
							# increment the number of empty doorways
							number_of_empty_doorways += 1
				# right of the current room
				elif iteration == 4:
					# check if there is a doorwat that points at the position to the left the room
					if room.has_door_right() && !room.has_connection_right():
						var target_room_position = room.global_position + Vector2(384, 0)
						# if the current position is not the target position and there is no room at that position
						if current_position != target_room_position && get_room_at_position(target_room_position) == null:
							# increment the number of empty doorways
							number_of_empty_doorways += 1
	# if the number of other empty doorways is greater than 0
	if number_of_empty_doorways > 0:
		return true
	# if the number of other empty doorways is 0
	else:
		return false

# gets the connection to the top of the current room
func get_connection_top(room_location):
	# for every room
	for adj_room in rooms:
		# if the room position matches the top connection of the current room
		if adj_room.global_position == room_location + Vector2(0, -224):
			if adj_room.has_door_bottom():
			# check if the adjacent room has a connecting door
				if !adj_room.has_connection_bottom():
					# return that room
					return adj_room
				# if the connection is not free
				else:
					return null
	# if there was no room that matches the position or didn't have a door to the bottom
	return null

# gets the connection to the bottom of the current room
func get_connection_bottom(room_location):
	# for every room
	for adj_room in rooms:
		# if the room position matches the bottom connection of the current room
		if adj_room.global_position == room_location + Vector2(0, 224):
			# check if the adjacent room has a connecting door
			if adj_room.has_door_top():
				# if the connection is free
				if !adj_room.has_connection_top():
					# return that room
					return adj_room
				# if the connection is not free
				else:
					return null
	# if there was no room that matches the position or didn't have a door to the top
	return null

# gets the connection to the left of the current room
func get_connection_left(room_location):
	# for every room
	for adj_room in rooms:
		# if the room position matches the left connection of the current room
		if adj_room.global_position == room_location + Vector2(-384, 0):
			# check if the adjacent room has a connecting door
			if adj_room.has_door_right():
				# if the connection is free
				if !adj_room.has_connection_right():
					# return that room
					return adj_room
				# if the connection is not free
				else:
					return null
	# if there was no room that matches the position or didn't have a door to the right
	return null

# gets the connection to the right of the current room
func get_connection_right(room_location):
	# for every room
	for adj_room in rooms:
		# if the room position matches the right connection of the current room
		if adj_room.global_position == room_location + Vector2(384, 0):
			# check if the adjacent room has a connecting door
			if adj_room.has_door_left():
				# if the connection is free
				if !adj_room.has_connection_left():
					# return that room
					return adj_room
				# if the connection is not free
				else:
					return null
	# if there was no room that matches the position or didn't have a door to the left
	return null

# gets the room at the current position
func get_room_at_position(room_location):
	# for every room in rooms
	for adj_room in rooms:
		# if the room is not null
		if adj_room != null:
			# if the room matches the room location
			if adj_room.global_position == room_location:
				# return the room
				return adj_room
	# if no room matched the room location, return null
	return null

# checks if the ending room can spawn
func check_if_ending_room_can_spawn(boss_room):
	# gets the connection of the boss room
	var top_connection = get_connection_top(boss_room.global_position)
	var bottom_connection = get_connection_bottom(boss_room.global_position)
	var left_connection = get_connection_left(boss_room.global_position)
	var right_connection = get_connection_right(boss_room.global_position)
	# sets up a new room
	var new_room
	# set the room as unable to spawn
	var can_spawn = false
	# if there is no top connection
	if top_connection == null:
		# set the target location
		var target_ending_room_position = boss_room.global_position + Vector2(0, -224)
		# check if a room can go at the target location
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_top():
			# set the top position as allowed
			var top_position_allowed = true
			# go through all rooms
			for adj_room in rooms:
				# if any rooms are adjacent to the target location
				# if any room has a door that points at the target location, the top position is not allowed
				if adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						top_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						top_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						top_position_allowed = false
			# set the can spawn value to the top position allowed
			can_spawn = top_position_allowed
	# if there is no bottom connection and the room cannot already spawn
	if bottom_connection == null && !can_spawn:
		# set the target location
		var target_ending_room_position = boss_room.global_position + Vector2(0, 224)
		# check if a room can go at the target location
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_bottom():
			# set the bottom position as allowed
			var bottom_position_allowed = true
			# go through all rooms
			for adj_room in rooms:
				# if any rooms are adjacent to the target location
				# if any room has a door that points at the target location, the bottom position is not allowed
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						bottom_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						bottom_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						bottom_position_allowed = false
			# set the can spawn value to the bottom position allowed
			can_spawn = bottom_position_allowed
	# if there is no left connection and the room cannot already spawn
	if left_connection == null && !can_spawn:
		# set the target location
		var target_ending_room_position = boss_room.global_position + Vector2(-384, 0)
		# check if a room can go at the target location
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_left():
			# set the left position as allowed
			var left_position_allowed = true
			# go through all rooms
			for adj_room in rooms:
				# if any rooms are adjacent to the target location
				# if any room has a door that points at the target location, the left position is not allowed
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						left_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						left_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						left_position_allowed = false
			# set the can spawn value to the left position allowed
			can_spawn = left_position_allowed
	# if there is no right connection and the room cannot already spawn
	if right_connection == null && !can_spawn:
		# set the target location
		var target_ending_room_position = boss_room.global_position + Vector2(384, 0)
		# check if a room can go at the target location
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_right():
			# set the right position as allowed
			var right_position_allowed = true
			for adj_room in rooms:
				# if any rooms are adjacent to the target location
				# if any room has a door that points at the target location, the right position is not allowed
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						right_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						right_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						right_position_allowed = false
			# set the can spawn value to the right position allowed
			can_spawn = right_position_allowed
	# return if the room can spawn
	return can_spawn

# returns which direction the ending room can spawn
func get_ending_room_spawn(boss_room):
	# gets the connection of the boss room
	var top_connection = get_connection_top(boss_room.global_position)
	var bottom_connection = get_connection_bottom(boss_room.global_position)
	var left_connection = get_connection_left(boss_room.global_position)
	var right_connection = get_connection_right(boss_room.global_position)
	# defines a new room
	var new_room
	# sets the can spawn
	var can_spawn = false
	# defines the spawn direction
	var spawn_direction = null
	# if there is no top connection
	if top_connection == null:
		# set the target location
		var target_ending_room_position = boss_room.global_position + Vector2(0, -224)
		# check if a room can go at the target location
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_top():
			# set the top position as allowed
			var top_position_allowed = true
			# goes through all rooms
			for adj_room in rooms:
				# if any rooms are adjacent to the target location
				# if any room has a door that points at the target location, the top position is not allowed
				if adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						top_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						top_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						top_position_allowed = false
			# sets the can spawn to top position allowed
			can_spawn = top_position_allowed
			# if the ending room can spawn
			if can_spawn:
				# sets the spawn direction to top
				spawn_direction = direction.top
	# if there is no bottom connection and the room cannot already spawn
	if bottom_connection == null && !can_spawn:
		# set the target location
		var target_ending_room_position = boss_room.global_position + Vector2(0, 224)
		# check if a room can go at the target location
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_bottom():
			# set the bottom position as allowed
			var bottom_position_allowed = true
			# goes through all rooms
			for adj_room in rooms:
				# if any rooms are adjacent to the target location
				# if any room has a door that points at the target location, the bottom position is not allowed
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						bottom_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						bottom_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						bottom_position_allowed = false
			# sets the can spawn to bottom position allowed
			can_spawn = bottom_position_allowed
			# if the ending room can spawn
			if can_spawn:
				# sets the spawn direction to bottom
				spawn_direction = direction.bottom
	# if there is no left connection and the room cannot already spawn
	if left_connection == null && !can_spawn:
		# set the target location
		var target_ending_room_position = boss_room.global_position + Vector2(-384, 0)
		# check if a room can go at the target location
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_left():
			# set the left position as allowed
			var left_position_allowed = true
			# goes through all rooms
			for adj_room in rooms:
				# if any rooms are adjacent to the target location
				# if any room has a door that points at the target location, the left position is not allowed
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						left_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						left_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						left_position_allowed = false
			# sets the can spawn to left position allowed
			can_spawn = left_position_allowed
			# if the ending room can spawn
			if can_spawn:
				# sets the spawn direction to left
				spawn_direction = direction.left
	# if there is no right connection and the room cannot already spawn
	if right_connection == null && !can_spawn:
		# set the target location
		var target_ending_room_position = boss_room.global_position + Vector2(384, 0)
		# check if a room can go at the target location
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_right():
			# set the right position as allowed
			var right_position_allowed = true
			# goes through all rooms
			for adj_room in rooms:
				# if any rooms are adjacent to the target location
				# if any room has a door that points at the target location, the right position is not allowed
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						right_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						right_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						right_position_allowed = false
			# sets the can spawn to right position allowed
			can_spawn = right_position_allowed
			# if the ending room can spawn
			if can_spawn:
				# sets the spawn direction to right
				spawn_direction = direction.right
	# returns the spawn direction
	return spawn_direction
