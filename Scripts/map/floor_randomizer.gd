extends Node2D

enum direction
{
	top,
	bottom,
	left,
	right,
}

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

var spawnable_room_types = [
	RoomData.room_types.random_item,
	RoomData.room_types.locked_item,
	RoomData.room_types.chest,
	RoomData.room_types.crystal_boss,
	RoomData.room_types.boss,
	RoomData.room_types.monster,
]

var spawnable_room_types_near_spawn = [
	RoomData.room_types.random_item,
	RoomData.room_types.locked_item,
	RoomData.room_types.chest,
	RoomData.room_types.monster,
]

var unlimited_room_types = [
	RoomData.room_types.monster,
	RoomData.room_types.no_type,
]

var rooms = []
var boss_room_spawned = false
var ending_room_spawned = false
var crystal_boss_room_spawned = false

var minimum_item_rooms = 1
var maximum_item_rooms = 2
var current_item_rooms = 0

var minimum_chest_rooms = 1
var maximum_chest_rooms = 2
var current_chest_rooms = 0

var minimum_locked_rooms = 1
var maximum_locked_rooms = 2
var current_locked_rooms = 0

var minimum_monster_rooms = 4
var current_monster_rooms = 0

var rng = RandomNumberGenerator.new()

var starting_room
var close_rooms = false
var minimum_requirements_met = false

func _ready():
	#spawn_starting_room()
	# when the room_entered signal is sent
	Events.room_entered.connect(func(room):
		are_minimum_requirements_met()
		if minimum_requirements_met:
			close_rooms = true
		spawn_adjacent_rooms(room)
	)

func start():
	spawn_starting_room()

func are_minimum_requirements_met():
	if !minimum_requirements_met:
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
		if item_room_met && monster_room_met && locked_rooms_met && chest_rooms_met && crystal_boss_room_spawned && boss_room_spawned && ending_room_spawned:
			minimum_requirements_met = true
		else:
			minimum_requirements_met = false
		print(minimum_requirements_met)

func random_room_type():
	var type
	if spawnable_room_types.size() != 0:
		type = spawnable_room_types[rng.randi_range(0,spawnable_room_types.size()-1)]
	if type != null:
		return type
	else:
		return unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]

func spawned_room_type(type : RoomData.room_types):
	if type == RoomData.room_types.random_item:
		current_item_rooms += 1
		if current_item_rooms == maximum_item_rooms:
			spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.random_item))
	elif type == RoomData.room_types.chest:
		current_chest_rooms += 1
		if current_chest_rooms == maximum_chest_rooms:
			spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.chest))
	elif type == RoomData.room_types.locked_item:
		current_locked_rooms += 1
		if current_locked_rooms == maximum_locked_rooms:
			spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.locked_item))
	elif type == RoomData.room_types.monster:
		current_monster_rooms += 1
	elif type == RoomData.room_types.crystal_boss:
		spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.crystal_boss))
		crystal_boss_room_spawned = true
	elif type == RoomData.room_types.boss:
		spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.boss))
		boss_room_spawned = true
	
	if spawnable_room_types.size() == 1 && spawnable_room_types[0] == RoomData.room_types.monster:
		spawnable_room_types.remove_at(0)

func random_room_type_near_spawn():
	var type
	if spawnable_room_types_near_spawn.size() != 0:
		type = spawnable_room_types_near_spawn[rng.randi_range(0,spawnable_room_types_near_spawn.size()-1)]
	if type != null:
		return type
	else:
		return unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]

func spawn_starting_room():
	var random_starting_room = rng.randi_range(0,all_rooms.size()-1)
	starting_room = all_rooms[random_starting_room].instantiate()
	starting_room.global_position = Vector2(0, 0)
	get_tree().current_scene.add_child(starting_room)
	starting_room.set_room_type(RoomData.room_types.starting)
	rooms += [starting_room]
	
	starting_room.refresh_type_text()
	
	starting_room.populate_room()

func spawn_adjacent_rooms(room):
	var connected_rooms = room.get_connected_rooms()
	var iteration = 0
	for connected_room in connected_rooms:
		var new_room
		var type
		if room == starting_room:
			type = random_room_type_near_spawn()
		else:
			type = random_room_type()
		var can_spawn_single_door_room = false
		if minimum_requirements_met:
			can_spawn_single_door_room = true
		iteration += 1
		if connected_room == null:
			# add a room to the top of the current room
			if iteration == 1:
				if room.has_door_top() && !room.has_connection_top():
					var target_room_position = room.global_position + Vector2(0, -224)
					
					if get_room_at_position(target_room_position) == null:
						
						if type == RoomData.room_types.locked_item || type == RoomData.room_types.boss || type == RoomData.room_types.crystal_boss:
							if !check_for_other_empty_doors(target_room_position):
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						var top_connection = get_connection_top(target_room_position)
						var left_connection = get_connection_left(target_room_position)
						var right_connection = get_connection_right(target_room_position)
						
						# needs to connect on all sides (down is implied)
						if top_connection != null && right_connection != null && left_connection != null:
							if type == RoomData.room_types.boss:
								type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
							new_room = _4_DOOR_ROOM.instantiate()
						# needs to connect on the top and right sides (down is implied)
						elif top_connection != null && right_connection != null && left_connection == null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							elif get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
								# get either room
								new_room = _4_DOOR_ROOM.instantiate()
							else:
								if type == RoomData.room_types.boss:
									type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
						# needs to connect on the top and left sides (down is implied)
						elif top_connection != null && right_connection == null && left_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							elif get_room_at_position(target_room_position + Vector2(384, 0)) == null:
								new_room = _4_DOOR_ROOM.instantiate()
							else:
								if type == RoomData.room_types.boss:
									type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
						# needs to connect on the left and right sides (down is implied)
						elif top_connection == null && right_connection != null && left_connection != null:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							elif get_room_at_position(target_room_position + Vector2(0, -224)) == null:
								new_room = _4_DOOR_ROOM.instantiate()
							else:
								if type == RoomData.room_types.boss:
									type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
						# needs to connect on the top side (down is implied)
						elif top_connection != null && right_connection == null && left_connection == null:
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
						# needs to connect on the right side (down is implied)
						elif top_connection == null && right_connection != null && left_connection == null:
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
						# needs to connect on the left side (down is implied)
						elif top_connection == null && right_connection == null && left_connection != null:
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
						# does not need to connect to any other sides (down is implied)
						else:
							if close_rooms || type == RoomData.room_types.locked_item || type == RoomData.room_types.crystal_boss:
								new_room = _1_DOOR_ROOM_DOWN.instantiate()
							else:
								var can_have_right = false
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									can_have_right = true
								var can_have_top = false
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									can_have_top = true
								var can_have_left = false
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									can_have_left = true
								
								if can_have_left && can_have_right && can_have_top:
									var random_number = rng.randi_range(0,rooms_that_can_connect_to_top.size()-1)
									if random_number == rooms_that_can_connect_to_top.size()-1:
										if !can_spawn_single_door_room:
											random_number = rng.randi_range(0,rooms_that_can_connect_to_top.size()-2)
									var random_room = rooms_that_can_connect_to_top[random_number]
									new_room = random_room.instantiate()
								elif can_have_left && can_have_right && !can_have_top:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif can_have_left && !can_have_right && can_have_top:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								elif !can_have_left && can_have_right && can_have_top:
									var temp_room = rng.randi_range(0,2)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								elif can_have_left && !can_have_right && !can_have_top:
									new_room = _2_DOOR_DOWN_LEFT.instantiate()
								elif !can_have_left && !can_have_right && can_have_top:
									new_room = _2_DOOR_UP_DOWN.instantiate()
								elif !can_have_left && can_have_right && !can_have_top:
									new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif !can_have_left && !can_have_right && !can_have_top:
									if type == RoomData.room_types.boss:
										type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
									new_room = _1_DOOR_ROOM_DOWN.instantiate()
						
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = target_room_position
						new_room.set_connected_room_top(top_connection)
						new_room.set_connected_room_bottom(room)
						new_room.set_connected_room_left(left_connection)
						new_room.set_connected_room_right(right_connection)
						rooms += [new_room]
						room.set_connected_room_top(new_room)
						
						if type == RoomData.room_types.boss && check_if_ending_room_can_spawn(new_room) == false:
							type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						new_room.set_room_type(type)
						
						new_room.refresh_type_text()
			# add a room to the bottom of the current room
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
						new_room.set_connected_room_left(left_connection)
						new_room.set_connected_room_right(right_connection)
						rooms += [new_room]
						room.set_connected_room_bottom(new_room)
						
						if type == RoomData.room_types.boss &&  check_if_ending_room_can_spawn(new_room) == false:
							type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						new_room.set_room_type(type)
						
						new_room.refresh_type_text()
			# add a room to the left of the current room
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
						new_room.set_connected_room_bottom(bottom_connection)
						new_room.set_connected_room_left(left_connection)
						new_room.set_connected_room_right(room)
						rooms += [new_room]
						room.set_connected_room_left(new_room)
						
						if type == RoomData.room_types.boss &&  check_if_ending_room_can_spawn(new_room) == false:
							type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						new_room.set_room_type(type)
						
						new_room.refresh_type_text()
			# add a room to the right of the current room
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
						new_room.set_connected_room_bottom(bottom_connection)
						new_room.set_connected_room_left(room)
						new_room.set_connected_room_right(right_connection)
						rooms += [new_room]
						room.set_connected_room_right(new_room)
						
						if type == RoomData.room_types.boss &&  check_if_ending_room_can_spawn(new_room) == false:
							type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
						
						new_room.set_room_type(type)
						
						new_room.refresh_type_text()
			
			if new_room != null:
				spawned_room_type(type)
				new_room.boss_icon_logic(false)
				if type ==  RoomData.room_types.boss:
					spawn_ending_room(new_room)
				new_room.populate_room()

func spawn_ending_room(boss_room):
	var new_room
	var ending_room_direction = get_ending_room_spawn(boss_room)
	
	if ending_room_direction == direction.top:
		var target_room_position = boss_room.global_position + Vector2(0, -224)
		if get_room_at_position(target_room_position) == null && boss_room.has_door_top():
			new_room = _1_DOOR_ROOM_DOWN.instantiate()
			
			get_tree().current_scene.add_child(new_room)
			new_room.global_position = target_room_position
			new_room.set_connected_room_bottom(boss_room)
			rooms += [new_room]
			boss_room.set_connected_room_top(new_room)
			
			new_room.set_room_type(RoomData.room_types.ending)
			
			new_room.refresh_type_text()
			
	elif ending_room_direction == direction.bottom:
		var target_room_position = boss_room.global_position + Vector2(0, 224)
		if get_room_at_position(target_room_position) == null && boss_room.has_door_bottom():
			new_room = _1_DOOR_ROOM_UP.instantiate()
			
			get_tree().current_scene.add_child(new_room)
			new_room.global_position = target_room_position
			new_room.set_connected_room_top(boss_room)
			rooms += [new_room]
			boss_room.set_connected_room_bottom(new_room)
			
			new_room.set_room_type(RoomData.room_types.ending)
			
			new_room.refresh_type_text()
			
	elif ending_room_direction == direction.left:
		var target_room_position = boss_room.global_position + Vector2(-384, 0)
		if get_room_at_position(target_room_position) == null && boss_room.has_door_left():
			new_room = _1_DOOR_ROOM_RIGHT.instantiate()
			
			get_tree().current_scene.add_child(new_room)
			new_room.global_position = target_room_position
			new_room.set_connected_room_right(boss_room)
			rooms += [new_room]
			boss_room.set_connected_room_left(new_room)
			
			new_room.set_room_type(RoomData.room_types.ending)
			
			new_room.refresh_type_text()
			
	elif ending_room_direction == direction.right:
		var target_room_position = boss_room.global_position + Vector2(384, 0)
		if get_room_at_position(target_room_position) == null && boss_room.has_door_right():
			new_room = _1_DOOR_ROOM_LEFT.instantiate()
			
			get_tree().current_scene.add_child(new_room)
			new_room.global_position = target_room_position
			new_room.set_connected_room_left(boss_room)
			rooms += [new_room]
			boss_room.set_connected_room_right(new_room)
			
			new_room.set_room_type(RoomData.room_types.ending)
			
			new_room.refresh_type_text()
	
	if new_room != null:
		ending_room_spawned = true
		new_room.populate_room()
	else:
		print("ending room didn't spawn")

func check_for_other_empty_doors(current_position : Vector2):
	var number_of_empty_doorways = 0
	for room in rooms:
		var connected_rooms = room.get_connected_rooms()
		var iteration = 0
		for connected_room in connected_rooms:
			iteration += 1
			if connected_room == null:
				# the top of the current room
				if iteration == 1:
					if room.has_door_top() && !room.has_connection_top():
						var target_room_position = room.global_position + Vector2(0, -224)
						if current_position != target_room_position && get_room_at_position(target_room_position) == null:
							number_of_empty_doorways += 1
				# bottom of the current room
				elif iteration == 2:
					if room.has_door_bottom() && !room.has_connection_bottom():
						var target_room_position = room.global_position + Vector2(0, 224)
						if current_position != target_room_position && get_room_at_position(target_room_position) == null:
							number_of_empty_doorways += 1
				# left of the current room
				elif iteration == 3:
					if room.has_door_left() && !room.has_connection_left():
						var target_room_position = room.global_position + Vector2(-384, 0)
						if current_position != target_room_position && get_room_at_position(target_room_position) == null:
							number_of_empty_doorways += 1
				# right of the current room
				elif iteration == 4:
					if room.has_door_right() && !room.has_connection_right():
						var target_room_position = room.global_position + Vector2(384, 0)
						if current_position != target_room_position && get_room_at_position(target_room_position) == null:
							number_of_empty_doorways += 1
	if number_of_empty_doorways > 0:
		return true
	else:
		return false

func get_connection_top(room_location):
	for adj_room in rooms:
		if adj_room.global_position == room_location + Vector2(0, -224):
			if adj_room.has_door_bottom():
				if !adj_room.has_connection_bottom():
					return adj_room
				else:
					return null
	return null

func get_connection_bottom(room_location):
	for adj_room in rooms:
		if adj_room.global_position == room_location + Vector2(0, 224):
			if adj_room.has_door_top():
				if !adj_room.has_connection_top():
					return adj_room
				else:
					return null
	return null

func get_connection_left(room_location):
	for adj_room in rooms:
		if adj_room.global_position == room_location + Vector2(-384, 0):
			if adj_room.has_door_right():
				if !adj_room.has_connection_right():
					return adj_room
				else:
					return null
	return null

func get_connection_right(room_location):
	for adj_room in rooms:
		if adj_room.global_position == room_location + Vector2(384, 0):
			if adj_room.has_door_left():
				if !adj_room.has_connection_left():
					return adj_room
				else:
					return null
	return null

func get_room_at_position(room_location):
	for adj_room in rooms:
		if adj_room != null:
			if adj_room.global_position == room_location:
				return adj_room
	return null

func check_if_ending_room_can_spawn(boss_room):
	var top_connection = get_connection_top(boss_room.global_position)
	var bottom_connection = get_connection_bottom(boss_room.global_position)
	var left_connection = get_connection_left(boss_room.global_position)
	var right_connection = get_connection_right(boss_room.global_position)
	
	var new_room
	var can_spawn = false
	
	if top_connection == null:
		var target_ending_room_position = boss_room.global_position + Vector2(0, -224)
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_top():
			var top_position_allowed = true
			for adj_room in rooms:
				if adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						top_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						top_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						top_position_allowed = false
			can_spawn = top_position_allowed
	if bottom_connection == null && !can_spawn:
		var target_ending_room_position = boss_room.global_position + Vector2(0, 224)
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_bottom():
			var bottom_position_allowed = true
			for adj_room in rooms:
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						bottom_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						bottom_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						bottom_position_allowed = false
			can_spawn = bottom_position_allowed
	if left_connection == null && !can_spawn:
		var target_ending_room_position = boss_room.global_position + Vector2(-384, 0)
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_left():
			var left_position_allowed = true
			for adj_room in rooms:
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						left_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						left_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						left_position_allowed = false
			can_spawn = left_position_allowed
	if right_connection == null && !can_spawn:
		var target_ending_room_position = boss_room.global_position + Vector2(384, 0)
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_right():
			var right_position_allowed = true
			for adj_room in rooms:
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						right_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						right_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						right_position_allowed = false
			can_spawn = right_position_allowed
	
	return can_spawn

func get_ending_room_spawn(boss_room):
	var top_connection = get_connection_top(boss_room.global_position)
	var bottom_connection = get_connection_bottom(boss_room.global_position)
	var left_connection = get_connection_left(boss_room.global_position)
	var right_connection = get_connection_right(boss_room.global_position)
	
	var new_room
	var can_spawn = false
	var spawn_direction = null
	
	if top_connection == null:
		var target_ending_room_position = boss_room.global_position + Vector2(0, -224)
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_top():
			var top_position_allowed = true
			for adj_room in rooms:
				if adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						top_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						top_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						top_position_allowed = false
			can_spawn = top_position_allowed
			if can_spawn:
				spawn_direction = direction.top
	if bottom_connection == null && !can_spawn:
		var target_ending_room_position = boss_room.global_position + Vector2(0, 224)
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_bottom():
			var bottom_position_allowed = true
			for adj_room in rooms:
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						bottom_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						bottom_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						bottom_position_allowed = false
			can_spawn = bottom_position_allowed
			if can_spawn:
				spawn_direction = direction.bottom
	if left_connection == null && !can_spawn:
		var target_ending_room_position = boss_room.global_position + Vector2(-384, 0)
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_left():
			var left_position_allowed = true
			for adj_room in rooms:
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						left_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						left_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(-384, 0):
					if adj_room.has_door_right():
						left_position_allowed = false
			can_spawn = left_position_allowed
			if can_spawn:
				spawn_direction = direction.left
	if right_connection == null && !can_spawn:
		var target_ending_room_position = boss_room.global_position + Vector2(384, 0)
		if get_room_at_position(target_ending_room_position) == null && boss_room.has_door_right():
			var right_position_allowed = true
			for adj_room in rooms:
				if adj_room.global_position == target_ending_room_position + Vector2(0, 224):
					if adj_room.has_door_top():
						right_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(0, -224):
					if adj_room.has_door_bottom():
						right_position_allowed = false
				elif adj_room.global_position == target_ending_room_position + Vector2(384, 0):
					if adj_room.has_door_left():
						right_position_allowed = false
			can_spawn = right_position_allowed
			if can_spawn:
				spawn_direction = direction.right
	
	return spawn_direction
