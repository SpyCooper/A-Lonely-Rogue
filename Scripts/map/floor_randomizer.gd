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
	_1_DOOR_ROOM_DOWN,
	_2_DOOR_DOWN_LEFT,
	_2_DOOR_DOWN_RIGHT,
	_2_DOOR_UP_DOWN,
	_3_DOOR_ROOM_NO_LEFT,
	_3_DOOR_ROOM_NO_RIGHT,
	_3_DOOR_ROOM_NO_UP,
	_4_DOOR_ROOM,
]

var rooms_that_can_connect_to_bottom = [
	_1_DOOR_ROOM_UP,
	_2_DOOR_ROOM_UP_LEFT,
	_2_DOOR_ROOM_UP_RIGHT,
	_2_DOOR_UP_DOWN,
	_3_DOOR_ROOM_NO_LEFT,
	_3_DOOR_ROOM_NO_RIGHT,
	_3_DOOR_ROOM_NO_DOWN,
	_4_DOOR_ROOM,
]

var rooms_that_can_connect_to_right = [
	_1_DOOR_ROOM_LEFT,
	_2_DOOR_DOWN_LEFT,
	_2_DOOR_LEFT_RIGHT,
	_2_DOOR_ROOM_UP_LEFT,
	_3_DOOR_ROOM_NO_DOWN,
	_3_DOOR_ROOM_NO_RIGHT,
	_3_DOOR_ROOM_NO_UP,
	_4_DOOR_ROOM,
]

var rooms_that_can_connect_to_left = [
	_1_DOOR_ROOM_RIGHT,
	_2_DOOR_DOWN_RIGHT,
	_2_DOOR_LEFT_RIGHT,
	_2_DOOR_ROOM_UP_RIGHT,
	_3_DOOR_ROOM_NO_DOWN,
	_3_DOOR_ROOM_NO_LEFT,
	_3_DOOR_ROOM_NO_UP,
	_4_DOOR_ROOM,
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

var unlimited_room_types = [
	RoomData.room_types.monster,
	RoomData.room_types.no_type,
]

var rooms = []
var boss_room_spawned = false
var ending_room_spawned = false
var crystal_boss_room_spawned = false

var minimum_item_rooms = 2
var maximum_item_rooms = 4
var current_item_rooms = 0

var maximum_chest_rooms = 3
var current_chest_rooms = 0

var minimum_locked_rooms = 1
var maximum_locked_rooms = 4
var current_locked_rooms = 0

var minimum_monster_rooms = 3
var current_monster_rooms = 0

var rng = RandomNumberGenerator.new()

var close_rooms = false

func _ready():
	#spawn_starting_room()
	# when the room_entered signal is sent
	Events.room_entered.connect(func(room):
		if minimum_requirements_met():
			close_rooms = true
		spawn_adjacent_rooms(room)
	)

func start():
	spawn_starting_room()

func minimum_requirements_met():
	var item_room_met = false
	var monster_room_met = false
	if current_item_rooms >= minimum_item_rooms:
		item_room_met = true
	if current_monster_rooms >= minimum_monster_rooms:
		monster_room_met = true
	#if current_locked_rooms >= minimum_locked_rooms:
		#print(" minimum locked rooms met")
		#checks += 1
	#if current_chest_rooms >= 0:
		#checks += 1
	return item_room_met && monster_room_met

func spawn_starting_room():
	var random_starting_room = rng.randi_range(0,all_rooms.size()-1)
	var starting_room = all_rooms[random_starting_room].instantiate()
	starting_room.global_position = Vector2(0, 0)
	get_tree().current_scene.add_child(starting_room)
	starting_room.set_room_type(RoomData.room_types.starting)
	rooms += [starting_room]
	
	starting_room.refresh_type_text()

func spawn_adjacent_rooms(room):
	var connected_rooms = room.get_connected_rooms()
	var iteration = 0
	for connected_room in connected_rooms:
		iteration += 1
		if connected_room == null:
			# add a room to the top of the current room
			if iteration == 1:
				if room.has_door_top() && !room.has_connection_top():
					var type = random_room_type()
					var new_room
					var target_room_position = room.global_position + Vector2(0, -224)
						
					if get_room_at_position(target_room_position) == null:
						var top_connection = get_connection_top(target_room_position)
						var left_connection = get_connection_left(target_room_position)
						var right_connection = get_connection_right(target_room_position)
						
						# needs to connect on all sides (down is implied)
						if top_connection != null && right_connection != null && left_connection != null:
							new_room = _4_DOOR_ROOM.instantiate()
						# needs to connect on the top and right sides (down is implied)
						elif top_connection != null && right_connection != null && left_connection == null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							elif get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
								# get either room
								var temp_room = rng.randi_range(0,1)
								if temp_room == 0:
									new_room = _4_DOOR_ROOM.instantiate()
								elif temp_room == 1:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							else:
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
						# needs to connect on the top and left sides (down is implied)
						elif top_connection != null && right_connection == null && left_connection != null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							elif get_room_at_position(target_room_position + Vector2(384, 0)) == null:
								# get either room
								var temp_room = rng.randi_range(0,1)
								if temp_room == 0:
									new_room = _4_DOOR_ROOM.instantiate()
								elif temp_room == 1:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							else:
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
						# needs to connect on the left and right sides (down is implied)
						elif top_connection == null && right_connection != null && left_connection != null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							elif get_room_at_position(target_room_position + Vector2(0, -224)) == null:
								# get either room
								var temp_room = rng.randi_range(0,1)
								if temp_room == 0:
									new_room = _4_DOOR_ROOM.instantiate()
								elif temp_room == 1:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							else:
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
						# needs to connect on the top side (down is implied)
						elif top_connection != null && right_connection == null && left_connection == null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								elif can_have_left && !can_have_right:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								elif !can_have_left && can_have_right:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								else:
									new_room = _2_DOOR_UP_DOWN.instantiate()
						# needs to connect on the right side (down is implied)
						elif top_connection == null && right_connection != null && left_connection == null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif can_have_left && !can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif !can_have_left && can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								else:
									new_room = _2_DOOR_DOWN_RIGHT.instantiate()
						# needs to connect on the left side (down is implied)
						elif top_connection == null && right_connection == null && left_connection != null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
								elif can_have_right && !can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
								elif !can_have_right && can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
								else:
									new_room = _2_DOOR_DOWN_LEFT.instantiate()
						# does not need to connect to any other sides (down is implied)
						else:
							if close_rooms:
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
									var random_room = rooms_that_can_connect_to_top[rng.randi_range(0,rooms_that_can_connect_to_top.size()-1)]
									new_room = random_room.instantiate()
								elif can_have_left && can_have_right && !can_have_top:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_DOWN.instantiate()
								elif can_have_left && !can_have_right && can_have_top:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_DOWN.instantiate()
								elif !can_have_left && can_have_right && can_have_top:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_DOWN.instantiate()
								elif can_have_left && !can_have_right && !can_have_top:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_DOWN.instantiate()
								elif !can_have_left && !can_have_right && can_have_top:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_UP_DOWN.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_DOWN.instantiate()
								elif !can_have_left && can_have_right && !can_have_top:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_DOWN.instantiate()
								else:
									new_room = _1_DOOR_ROOM_DOWN.instantiate()
						
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = target_room_position
						new_room.set_connected_room_top(top_connection)
						new_room.set_connected_room_bottom(room)
						new_room.set_connected_room_left(left_connection)
						new_room.set_connected_room_right(right_connection)
						rooms += [new_room]
						room.set_connected_room_top(new_room)
						
						new_room.set_room_type(type)
						
						new_room.refresh_type_text()
			# add a room to the bottom of the current room
			elif iteration == 2:
				if room.has_door_bottom() && !room.has_connection_bottom():
					var type = random_room_type()
					var new_room
					var target_room_position = room.global_position + Vector2(0, 224)
					
					if get_room_at_position(target_room_position) == null:
						var bottom_connection = get_connection_bottom(target_room_position)
						var left_connection = get_connection_left(target_room_position)
						var right_connection = get_connection_right(target_room_position)
						
						if bottom_connection != null && right_connection != null && left_connection != null:
							new_room = _4_DOOR_ROOM.instantiate()
						elif bottom_connection != null && right_connection != null && left_connection == null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									# get either room
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								else:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
						elif bottom_connection != null && right_connection == null && left_connection != null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									# get either room
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								else:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
						elif bottom_connection == null && right_connection != null && left_connection != null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									# get either room
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								else:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
						elif bottom_connection != null && right_connection == null && left_connection == null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								elif can_have_left && !can_have_right:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								elif !can_have_left && can_have_right:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_UP_DOWN.instantiate()
								else:
									new_room = _2_DOOR_UP_DOWN.instantiate()
						elif bottom_connection == null && right_connection != null && left_connection == null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif can_have_left && !can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif !can_have_left && can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								else:
									new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
						elif bottom_connection == null && right_connection == null && left_connection != null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif can_have_right && !can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif !can_have_right && can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								else:
									new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
						else:
							if close_rooms:
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
									var random_room = rooms_that_can_connect_to_bottom[rng.randi_range(0,rooms_that_can_connect_to_bottom.size()-1)]
									new_room = random_room.instantiate()
								elif can_have_left && can_have_right && !can_have_bottom:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_UP.instantiate()
								elif can_have_left && !can_have_right && can_have_bottom:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_UP_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_UP.instantiate()
								elif !can_have_left && can_have_right && can_have_bottom:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_UP_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_UP.instantiate()
								elif can_have_left && !can_have_right && !can_have_bottom:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_UP.instantiate()
								elif !can_have_left && !can_have_right && can_have_bottom:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_UP_DOWN.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_UP.instantiate()
								elif !can_have_left && can_have_right && !can_have_bottom:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_UP.instantiate()
								else:
									new_room = _1_DOOR_ROOM_UP.instantiate()
							
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = target_room_position
						new_room.set_connected_room_top(room)
						new_room.set_connected_room_bottom(bottom_connection)
						new_room.set_connected_room_left(left_connection)
						new_room.set_connected_room_right(right_connection)
						rooms += [new_room]
						room.set_connected_room_bottom(new_room)
						
						new_room.set_room_type(type)
						
						new_room.refresh_type_text()
			# add a room to the left of the current room
			elif iteration == 3:
				if room.has_door_left() && !room.has_connection_left():
					var type = random_room_type()
					var new_room
					var target_room_position = room.global_position + Vector2(-384, 0)
					
					if get_room_at_position(target_room_position) == null:
						var top_connection = get_connection_top(target_room_position)
						var bottom_connection = get_connection_bottom(target_room_position)
						var left_connection = get_connection_left(target_room_position)
						
						if top_connection != null && bottom_connection != null && left_connection != null:
							new_room = _4_DOOR_ROOM.instantiate()
						elif top_connection != null && bottom_connection != null && left_connection == null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
									# get either room
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								else:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
						elif top_connection != null && bottom_connection == null && left_connection != null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									# get either room
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								else:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
						elif top_connection == null && bottom_connection != null && left_connection != null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									# get either room
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								else:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
						elif top_connection != null && bottom_connection == null && left_connection == null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif can_have_left && !can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif !can_have_left && can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								else:
									new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
						elif top_connection == null && bottom_connection != null && left_connection == null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif can_have_left && !can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif !can_have_left && can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								else:
									new_room = _2_DOOR_DOWN_RIGHT.instantiate()
						elif top_connection == null && bottom_connection == null && left_connection != null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								elif can_have_bottom && !can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								elif !can_have_bottom && can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								else:
									new_room = _2_DOOR_LEFT_RIGHT.instantiate()
						else:
							if close_rooms:
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
									var random_room = rooms_that_can_connect_to_left[rng.randi_range(0,rooms_that_can_connect_to_left.size()-1)]
									new_room = random_room.instantiate()
								elif can_have_left && can_have_top && !can_have_bottom:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_RIGHT.instantiate()
								elif can_have_left && !can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_RIGHT.instantiate()
								elif !can_have_left && can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_RIGHT.instantiate()
								elif can_have_left && !can_have_top && !can_have_bottom:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_RIGHT.instantiate()
								elif !can_have_left && !can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_DOWN_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_RIGHT.instantiate()
								elif !can_have_left && can_have_top && !can_have_bottom:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_RIGHT.instantiate()
								else:
									new_room = _1_DOOR_ROOM_RIGHT.instantiate()
						
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = target_room_position
						new_room.set_connected_room_top(top_connection)
						new_room.set_connected_room_bottom(bottom_connection)
						new_room.set_connected_room_left(left_connection)
						new_room.set_connected_room_right(room)
						rooms += [new_room]
						room.set_connected_room_left(new_room)
						
						new_room.set_room_type(type)
						
						new_room.refresh_type_text()
			# add a room to the right of the current room
			elif iteration == 4:
				if room.has_door_right() && !room.has_connection_right():
					var type = random_room_type()
					var new_room
					var target_room_position = room.global_position + Vector2(384, 0)
					
					if get_room_at_position(target_room_position) == null:
						var top_connection = get_connection_top(target_room_position)
						var bottom_connection = get_connection_bottom(target_room_position)
						var right_connection = get_connection_right(target_room_position)
						
						if top_connection != null && bottom_connection != null && right_connection != null:
							new_room = _4_DOOR_ROOM.instantiate()
						elif top_connection != null && bottom_connection != null && right_connection == null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
									# get either room
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								else:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
						elif top_connection != null && bottom_connection == null && right_connection != null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, 224)) == null:
									# get either room
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								else:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
						elif top_connection == null && bottom_connection != null && right_connection != null:
							if close_rooms:
								new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							else:
								if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
									# get either room
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								else:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
						elif top_connection != null && bottom_connection == null && right_connection == null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif can_have_right && !can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif !can_have_right && can_have_bottom:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								else:
									new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
						elif top_connection == null && bottom_connection != null && right_connection == null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
								elif can_have_right && !can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
								elif !can_have_right && can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
								else:
									new_room = _2_DOOR_DOWN_LEFT.instantiate()
						elif top_connection == null && bottom_connection == null && right_connection != null:
							if close_rooms:
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
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _4_DOOR_ROOM.instantiate()
									elif temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 3:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								elif can_have_bottom && !can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								elif !can_have_bottom && can_have_top:
									# get any room
									var temp_room = rng.randi_range(1,2)
									if temp_room == 1:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								else:
									new_room = _2_DOOR_LEFT_RIGHT.instantiate()
						else:
							if close_rooms:
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
									var random_room = rooms_that_can_connect_to_right[rng.randi_range(0,rooms_that_can_connect_to_right.size()-1)]
									new_room = random_room.instantiate()
								elif can_have_right && can_have_top && !can_have_bottom:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_LEFT.instantiate()
								elif can_have_right && !can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_UP.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_LEFT.instantiate()
								elif !can_have_right && can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,3)
									if temp_room == 0:
										new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
									elif temp_room == 2:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 3:
										new_room = _1_DOOR_ROOM_LEFT.instantiate()
								elif can_have_right && !can_have_top && !can_have_bottom:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_LEFT_RIGHT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_LEFT.instantiate()
								elif !can_have_right && !can_have_top && can_have_bottom:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_DOWN_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_LEFT.instantiate()
								elif !can_have_right && can_have_top && !can_have_bottom:
									var temp_room = rng.randi_range(0,1)
									if temp_room == 0:
										new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
									elif temp_room == 1:
										new_room = _1_DOOR_ROOM_LEFT.instantiate()
								else:
									new_room = _1_DOOR_ROOM_LEFT.instantiate()
						
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = target_room_position
						new_room.set_connected_room_top(top_connection)
						new_room.set_connected_room_bottom(bottom_connection)
						new_room.set_connected_room_left(room)
						new_room.set_connected_room_right(right_connection)
						rooms += [new_room]
						room.set_connected_room_right(new_room)
						
						new_room.set_room_type(type)
						
						new_room.refresh_type_text()

func random_room_type():
	var type = spawnable_room_types[rng.randi_range(0,spawnable_room_types.size()-1)]
	if type == RoomData.room_types.random_item:
		if current_item_rooms == maximum_item_rooms:
			spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.random_item))
			type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
			if type == RoomData.room_types.monster:
				current_monster_rooms += 1
			return type
		else:
			current_item_rooms += 1
			return RoomData.room_types.random_item
	#elif type == RoomData.room_types.chest:
		#if current_chest_rooms == maximum_chest_rooms:
			#spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.chest))
			#type = rng.randi_range(0,unlimited_room_types.size()-1)
			#if type == RoomData.room_types.monster:
				#current_monster_rooms += 1
			#return type
		#else:
			#current_chest_rooms += 1
	#elif type == RoomData.room_types.locked_item:
		#if current_locked_rooms == maximum_locked_rooms:
			#spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.locked_item))
			#type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
			#if type == RoomData.room_types.monster:
				#current_monster_rooms += 1
			#return type
		#else:
			#current_locked_rooms += 1
			#return type
	else:
		type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
		if type == RoomData.room_types.monster:
			current_monster_rooms += 1
		return type

#func spawn_required_rooms():
	#while !minimum_requirements_met():
		#var random_room_type = spawnable_room_types[rng.randi_range(0,spawnable_room_types.size()-1)]
		#if random_room_type == RoomData.room_types.random_item:
			#if current_item_rooms == maximum_item_rooms:
				#spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.random_item))
				#random_room_type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
				#add_new_room_at_random_position(random_room_type)
				#if random_room_type == RoomData.room_types.monster:
					#current_monster_rooms += 1
			#else:
				#add_new_room_at_random_position(random_room_type)
				#current_item_rooms += 1
		##elif random_room_type == RoomData.room_types.monster:
			##add_new_room_at_random_position(RoomData.room_types.monster)
			##current_monster_rooms += 1
		#elif random_room_type == RoomData.room_types.chest:
			#if current_chest_rooms == maximum_chest_rooms:
				#spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.chest))
				#random_room_type = rng.randi_range(0,unlimited_room_types.size()-1)
				#add_new_room_at_random_position(unlimited_room_types[random_room_type])
			#else:
				#add_new_room_at_random_position(random_room_type)
				#current_chest_rooms += 1
		#elif random_room_type == RoomData.room_types.locked_item:
			#if current_locked_rooms == maximum_locked_rooms:
				#spawnable_room_types.remove_at(spawnable_room_types.find(RoomData.room_types.locked_item))
				#random_room_type = rng.randi_range(0,unlimited_room_types.size()-1)
				#add_new_room_at_random_position(unlimited_room_types[random_room_type])
			#else:
				#add_new_room_at_random_position(random_room_type)
				#current_chest_rooms += 1
		##elif random_room_type == RoomData.room_types.starting:
			##add_new_room_at_random_position(RoomData.room_types.monster)
			##current_monster_rooms += 1
		#else:
			##print(random_room_type)
			#pass
#
#func add_new_room_at_random_position(type : RoomData.room_types):
	#var random_room = rng.randi_range(0,rooms.size()-1)
	#var has_not_random_connection = true
	#var new_room_direction
	#while has_not_random_connection:
		#var random_direction = rng.randi_range(0,directions.size()-1)
		#if random_direction == direction.top:
			#if rooms[random_room].has_door_top() && !rooms[random_room].has_connection_top():
				#new_room_direction = random_direction
				#has_not_random_connection = false
		#elif random_direction == direction.bottom:
			#if rooms[random_room].has_door_bottom() && !rooms[random_room].has_connection_bottom():
				#new_room_direction = random_direction
				#has_not_random_connection = false
		#elif random_direction == direction.left:
			#if rooms[random_room].has_door_left() && !rooms[random_room].has_connection_left():
				#new_room_direction = random_direction
				#has_not_random_connection = false
		#elif random_direction == direction.right:
			#if rooms[random_room].has_door_right() && !rooms[random_room].has_connection_right():
				#new_room_direction = random_direction
				#has_not_random_connection = false
	#
	#if new_room_direction == direction.top:
		#var target_room_position = rooms[random_room].global_position + Vector2(0, -224)
		#
		#if get_room_at_position(target_room_position) == null:
			#var new_room = rooms_that_can_connect_to_top[rng.randi_range(0,rooms_that_can_connect_to_top.size()-1)].instantiate()
			#
			#var top_connection = get_connection_top(target_room_position)
			#var left_connection = get_connection_left(target_room_position)
			#var right_connection = get_connection_right(target_room_position)
			#
			## needs to connect on all sides (down is implied)
			#if top_connection != null && right_connection != null && left_connection != null:
				#new_room = _4_DOOR_ROOM.instantiate()
			## needs to connect on the top and right sides (down is implied)
			#elif top_connection != null && right_connection != null && left_connection == null:
				#if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
					## get either room
					#var temp_room = rng.randi_range(0,1)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
				#else:
					#new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
			## needs to connect on the top and left sides (down is implied)
			#elif top_connection != null && right_connection == null && left_connection != null:
				#if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
					## get either room
					#var temp_room = rng.randi_range(0,1)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
				#else:
					#new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
			## needs to connect on the left and right sides (down is implied)
			#elif top_connection == null && right_connection != null && left_connection != null:
				#if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
					## get either room
					#var temp_room = rng.randi_range(0,1)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_UP.instantiate()
				#else:
					#new_room = _3_DOOR_ROOM_NO_UP.instantiate()
			## needs to connect on the top side (down is implied)
			#elif top_connection != null && right_connection == null && left_connection == null:
				#var can_have_left = false
				#if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
					#can_have_left = true
				#var can_have_right = false
				#if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
					#can_have_right = true
				#
				#if can_have_left && can_have_right:
					## get any room
					#var temp_room = rng.randi_range(0,3)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
					#elif temp_room == 2:
						#new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
					#elif temp_room == 3:
						#new_room = _2_DOOR_UP_DOWN.instantiate()
				#elif can_have_left && !can_have_right:
					## get any room
					#var temp_room = rng.randi_range(0,2)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
					#elif temp_room == 2:
						#new_room = _2_DOOR_UP_DOWN.instantiate()
				#elif !can_have_left && can_have_right:
					## get any room
					#var temp_room = rng.randi_range(0,2)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
					#elif temp_room == 2:
						#new_room = _2_DOOR_UP_DOWN.instantiate()
				#else:
					#new_room = _2_DOOR_UP_DOWN.instantiate()
			## needs to connect on the right side (down is implied)
			#elif top_connection == null && right_connection != null && left_connection == null:
				#var can_have_left = false
				#if get_room_at_position(target_room_position + Vector2(-384, 0)) == null:
					#can_have_left = true
				#var can_have_top = false
				#if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
					#can_have_top = true
				#
				#if can_have_left && can_have_top:
					## get any room
					#var temp_room = rng.randi_range(0,3)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_UP.instantiate()
					#elif temp_room == 2:
						#new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
					#elif temp_room == 3:
						#new_room = _2_DOOR_DOWN_RIGHT.instantiate()
				#elif can_have_left && !can_have_top:
					## get any room
					#var temp_room = rng.randi_range(0,2)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_UP.instantiate()
					#elif temp_room == 2:
						#new_room = _2_DOOR_DOWN_RIGHT.instantiate()
				#elif !can_have_left && can_have_top:
					## get any room
					#var temp_room = rng.randi_range(0,2)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
					#elif temp_room == 2:
						#new_room = _2_DOOR_DOWN_RIGHT.instantiate()
				#else:
					#new_room = _2_DOOR_DOWN_RIGHT.instantiate()
			## needs to connect on the left side (down is implied)
			#elif top_connection == null && right_connection == null && left_connection != null:
				#var can_have_right = false
				#if get_room_at_position(target_room_position + Vector2(384, 0)) == null:
					#can_have_right = true
				#var can_have_top = false
				#if get_room_at_position(target_room_position + Vector2(0, -224)) == null:
					#can_have_top = true
				#
				#if can_have_right && can_have_top:
					## get any room
					#var temp_room = rng.randi_range(0,3)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_UP.instantiate()
					#elif temp_room == 2:
						#new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
					#elif temp_room == 3:
						#new_room = _2_DOOR_DOWN_LEFT.instantiate()
				#elif can_have_right && !can_have_top:
					## get any room
					#var temp_room = rng.randi_range(0,2)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_UP.instantiate()
					#elif temp_room == 2:
						#new_room = _2_DOOR_DOWN_LEFT.instantiate()
				#elif !can_have_right && can_have_top:
					## get any room
					#var temp_room = rng.randi_range(0,2)
					#if temp_room == 0:
						#new_room = _4_DOOR_ROOM.instantiate()
					#elif temp_room == 1:
						#new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
					#elif temp_room == 2:
						#new_room = _2_DOOR_DOWN_LEFT.instantiate()
				#else:
					#new_room = _2_DOOR_DOWN_LEFT.instantiate()
			## does not need to connect to any other sides (down is implied)
			#else:
				#new_room = _1_DOOR_ROOM_DOWN.instantiate()
			#
			#get_tree().current_scene.add_child(new_room)
			#new_room.global_position = target_room_position
			#new_room.set_connected_room_top(top_connection)
			#new_room.set_connected_room_bottom(rooms[random_room])
			#new_room.set_connected_room_left(left_connection)
			#new_room.set_connected_room_right(right_connection)
			#rooms += [new_room]
			#rooms[random_room].set_connected_room_top(new_room)
			#
			#new_room.set_room_type(type)
	#elif new_room_direction == direction.bottom:
		#var new_room = rooms_that_can_connect_to_bottom[rng.randi_range(0,rooms_that_can_connect_to_bottom.size()-1)].instantiate()
		#var target_room_position = rooms[random_room].global_position + Vector2(0, 224)
		#
		#if get_room_at_position(target_room_position) == null:
			#var bottom_connection = get_connection_bottom(target_room_position)
			#var left_connection = get_connection_left(target_room_position)
			#var right_connection = get_connection_right(target_room_position)
			#
			#get_tree().current_scene.add_child(new_room)
			#new_room.global_position = target_room_position
			#new_room.set_connected_room_top(rooms[random_room])
			#new_room.set_connected_room_bottom(bottom_connection)
			#new_room.set_connected_room_left(left_connection)
			#new_room.set_connected_room_right(right_connection)
			#rooms += [new_room]
			#rooms[random_room].set_connected_room_bottom(new_room)
			#
			#new_room.set_room_type(type)
	#elif new_room_direction == direction.left:
		#var new_room = rooms_that_can_connect_to_left[rng.randi_range(0,rooms_that_can_connect_to_left.size()-1)].instantiate()
		#var target_room_position = rooms[random_room].global_position + Vector2(-384, 0)
		#
		#if get_room_at_position(target_room_position) == null:
			#var top_connection = get_connection_top(target_room_position)
			#var bottom_connection = get_connection_bottom(target_room_position)
			#var left_connection = get_connection_left(target_room_position)
			#
			#get_tree().current_scene.add_child(new_room)
			#new_room.global_position = target_room_position
			#new_room.set_connected_room_top(top_connection)
			#new_room.set_connected_room_bottom(bottom_connection)
			#new_room.set_connected_room_left(left_connection)
			#new_room.set_connected_room_right(rooms[random_room])
			#rooms += [new_room]
			#rooms[random_room].set_connected_room_left(new_room)
			#
			#new_room.set_room_type(type)
	#elif new_room_direction == direction.right:
		#var new_room = rooms_that_can_connect_to_right[rng.randi_range(0,rooms_that_can_connect_to_right.size()-1)].instantiate()
		#var target_room_position = rooms[random_room].global_position + Vector2(384, 0)
		#
		#if get_room_at_position(target_room_position) == null:
			#var top_connection = get_connection_top(target_room_position)
			#var bottom_connection = get_connection_bottom(target_room_position)
			#var right_connection = get_connection_right(target_room_position)
			#
			#get_tree().current_scene.add_child(new_room)
			#new_room.global_position = target_room_position
			#new_room.set_connected_room_top(top_connection)
			#new_room.set_connected_room_bottom(bottom_connection)
			#new_room.set_connected_room_left(rooms[random_room])
			#new_room.set_connected_room_right(right_connection)
			#rooms += [new_room]
			#rooms[random_room].set_connected_room_right(new_room)
			#
			#new_room.set_room_type(type)

#func finish_connecting_rooms():
	#for room in rooms:
		#var connected_rooms = room.get_connected_rooms()
		#var iteration = 0
		#for connected_room in connected_rooms:
			#iteration += 1
			#if connected_room == null:
				## add a room to the top of the current room
				#if iteration == 1:
					#if room.has_door_top() && !room.has_connection_top():
						#var new_room
						#var target_room_position = room.global_position + Vector2(0, -224)
						#
						#if get_room_at_position(target_room_position) == null:
							##var random_room = rng.randi_range(0,3)
							##if random_room == 2:
								##new_room = _4_DOOR_ROOM.instantiate()
							#
							#var top_connection = get_connection_top(target_room_position)
							#var left_connection = get_connection_left(target_room_position)
							#var right_connection = get_connection_right(target_room_position)
							#
							#if top_connection != null && right_connection != null && left_connection != null:
								#new_room = _4_DOOR_ROOM.instantiate()
							#elif top_connection != null && right_connection != null && left_connection == null:
								#new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							#elif top_connection != null && right_connection == null && left_connection != null:
								#new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							#elif top_connection == null && right_connection != null && left_connection != null:
								#new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							#elif top_connection != null && right_connection == null && left_connection == null:
								#new_room = _2_DOOR_UP_DOWN.instantiate()
							#elif top_connection == null && right_connection != null && left_connection == null:
								#new_room = _2_DOOR_DOWN_RIGHT.instantiate()
							#elif top_connection == null && right_connection == null && left_connection != null:
								#new_room = _2_DOOR_DOWN_LEFT.instantiate()
							#else:
								#new_room = _1_DOOR_ROOM_DOWN.instantiate()
							#
							#get_tree().current_scene.add_child(new_room)
							#new_room.global_position = target_room_position
							#new_room.set_connected_room_top(top_connection)
							#new_room.set_connected_room_bottom(room)
							#new_room.set_connected_room_left(left_connection)
							#new_room.set_connected_room_right(right_connection)
							#rooms += [new_room]
							#room.set_connected_room_top(new_room)
							#
							#var random_type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
							#new_room.set_room_type(random_type)
							#
							#new_room.refresh_type_text()
				## add a room to the bottom of the current room
				#elif iteration == 2:
					#if room.has_door_bottom() && !room.has_connection_bottom():
						#var new_room
						#var target_room_position = room.global_position + Vector2(0, 224)
						#
						#if get_room_at_position(target_room_position) == null:
								##var random_room = rng.randi_range(0,3)
								##if random_room == 2:
									##new_room = _4_DOOR_ROOM.instantiate()
								#
							#var bottom_connection = get_connection_bottom(target_room_position)
							#var left_connection = get_connection_left(target_room_position)
							#var right_connection = get_connection_right(target_room_position)
							#
							#if bottom_connection != null && right_connection != null && left_connection != null:
								#new_room = _4_DOOR_ROOM.instantiate()
							#elif bottom_connection != null && right_connection != null && left_connection == null:
								#new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							#elif bottom_connection != null && right_connection == null && left_connection != null:
								#new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							#elif bottom_connection == null && right_connection != null && left_connection != null:
								#new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
							#elif bottom_connection != null && right_connection == null && left_connection == null:
								#new_room = _2_DOOR_UP_DOWN.instantiate()
							#elif bottom_connection == null && right_connection != null && left_connection == null:
								#new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
							#elif bottom_connection == null && right_connection == null && left_connection != null:
								#new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
							#else:
								#new_room = _1_DOOR_ROOM_UP.instantiate()
							#
							#get_tree().current_scene.add_child(new_room)
							#new_room.global_position = target_room_position
							#new_room.set_connected_room_top(room)
							#new_room.set_connected_room_bottom(bottom_connection)
							#new_room.set_connected_room_left(left_connection)
							#new_room.set_connected_room_right(right_connection)
							#rooms += [new_room]
							#room.set_connected_room_bottom(new_room)
							#
							#var random_type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
							#new_room.set_room_type(random_type)
							#
							#new_room.refresh_type_text()
					## add a room to the left of the current room
				#elif iteration == 3:
					#if room.has_door_left() && !room.has_connection_left():
						#var new_room
						#var target_room_position = room.global_position + Vector2(-384, 0)
						#
						#if get_room_at_position(target_room_position) == null:
							##var random_room = rng.randi_range(0,3)
							##if random_room == 2:
								##new_room = _4_DOOR_ROOM.instantiate()
							#
							#var top_connection = get_connection_top(target_room_position)
							#var bottom_connection = get_connection_bottom(target_room_position)
							#var left_connection = get_connection_left(target_room_position)
							#
							#if top_connection != null && bottom_connection != null && left_connection != null:
								#new_room = _4_DOOR_ROOM.instantiate()
							#elif top_connection != null && bottom_connection != null && left_connection == null:
								#new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
							#elif top_connection != null && bottom_connection == null && left_connection != null:
								#new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
							#elif top_connection == null && bottom_connection != null && left_connection != null:
								#new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							#elif top_connection != null && bottom_connection == null && left_connection == null:
								#new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
							#elif top_connection == null && bottom_connection != null && left_connection == null:
								#new_room = _2_DOOR_DOWN_RIGHT.instantiate()
							#elif top_connection == null && bottom_connection == null && left_connection != null:
								#new_room = _2_DOOR_LEFT_RIGHT.instantiate()
							#else:
								#new_room = _1_DOOR_ROOM_RIGHT.instantiate()
							#
							#get_tree().current_scene.add_child(new_room)
							#new_room.global_position = target_room_position
							#new_room.set_connected_room_top(top_connection)
							#new_room.set_connected_room_bottom(bottom_connection)
							#new_room.set_connected_room_left(left_connection)
							#new_room.set_connected_room_right(room)
							#rooms += [new_room]
							#room.set_connected_room_left(new_room)
							#
							#var random_type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
							#new_room.set_room_type(random_type)
							#
							#new_room.refresh_type_text()
				## add a room to the right of the current room
				#elif iteration == 4:
					#if room.has_door_right() && !room.has_connection_right():
						#var new_room
						#var target_room_position = room.global_position + Vector2(384, 0)
						#
						#if get_room_at_position(target_room_position) == null:
							##var random_room = rng.randi_range(0,3)
							##if random_room == 2:
								##new_room = _4_DOOR_ROOM.instantiate()
							#
							#var top_connection = get_connection_top(target_room_position)
							#var bottom_connection = get_connection_bottom(target_room_position)
							#var right_connection = get_connection_right(target_room_position)
							#
							#if top_connection != null && bottom_connection != null && right_connection != null:
								#new_room = _4_DOOR_ROOM.instantiate()
							#elif top_connection != null && bottom_connection != null && right_connection == null:
								#new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
							#elif top_connection != null && bottom_connection == null && right_connection != null:
								#new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
							#elif top_connection == null && bottom_connection != null && right_connection != null:
								#new_room = _3_DOOR_ROOM_NO_UP.instantiate()
							#elif top_connection != null && bottom_connection == null && right_connection == null:
								#new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
							#elif top_connection == null && bottom_connection != null && right_connection == null:
								#new_room = _2_DOOR_DOWN_LEFT.instantiate()
							#elif top_connection == null && bottom_connection == null && right_connection != null:
								#new_room = _2_DOOR_LEFT_RIGHT.instantiate()
							#elif top_connection == null && bottom_connection == null && right_connection == null:
								#new_room = _1_DOOR_ROOM_LEFT.instantiate()
							#
							#get_tree().current_scene.add_child(new_room)
							#new_room.global_position = target_room_position
							#new_room.set_connected_room_top(top_connection)
							#new_room.set_connected_room_bottom(bottom_connection)
							#new_room.set_connected_room_left(room)
							#new_room.set_connected_room_right(right_connection)
							#rooms += [new_room]
							#room.set_connected_room_right(new_room)
							#
							#var random_type = unlimited_room_types[rng.randi_range(0,unlimited_room_types.size()-1)]
							#new_room.set_room_type(random_type)
							#
							#new_room.refresh_type_text()

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

func populate_rooms():
	pass
