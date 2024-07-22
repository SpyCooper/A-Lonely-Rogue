extends Node2D

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

var rooms = []

var rng = RandomNumberGenerator.new()

func start():
	spawn_rooms()


func spawn_rooms():
	var starting_room = _4_DOOR_ROOM.instantiate()
	starting_room.global_position = Vector2(0, 0)
	get_tree().current_scene.add_child(starting_room)
	rooms += [starting_room]
	
	var added_new_room = true
	while added_new_room:
		added_new_room = false
		for room in rooms:
			var connected_rooms = room.get_connected_rooms()
			var iteration = 0
			for connected_room in connected_rooms:
				iteration += 1
				if connected_room == null:
					# add a room to the top of the current room
					if iteration == 1:
						var new_room = _1_DOOR_ROOM_DOWN.instantiate()
						var random_room = rng.randi_range(0,3)
						if random_room == 2:
							new_room = _4_DOOR_ROOM.instantiate()
						
						# basic idea (this crashes)
						#var random_room = rng.randi_range(0,rooms_that_can_connect_to_top.size())
						#var new_room = rooms_that_can_connect_to_top[random_room].instantiate()
						
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = room.global_position + Vector2(0, -224)
						new_room.set_connected_room_bottom(room)
						rooms += [new_room]
						added_new_room = true
						room.set_connected_room_top(new_room)
					# add a room to the bottom of the current room
					elif iteration == 2:
						var new_room = _1_DOOR_ROOM_UP.instantiate()
						var random_room = rng.randi_range(0,3)
						if random_room == 2:
							new_room = _4_DOOR_ROOM.instantiate()
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = room.global_position + Vector2(0, 224)
						new_room.set_connected_room_top(room)
						rooms += [new_room]
						added_new_room = true
						room.set_connected_room_bottom(new_room)
					# add a room to the left of the current room
					elif iteration == 3:
						var new_room = _1_DOOR_ROOM_RIGHT.instantiate()
						var random_room = rng.randi_range(0,3)
						if random_room == 2:
							new_room = _4_DOOR_ROOM.instantiate()
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = room.global_position + Vector2(-384, 0)
						new_room.set_connected_room_right(room)
						rooms += [new_room]
						added_new_room = true
						room.set_connected_room_left(new_room)
					# add a room to the right of the current room
					elif iteration == 4:
						var new_room = _1_DOOR_ROOM_LEFT.instantiate()
						var random_room = rng.randi_range(0,3)
						if random_room == 2:
							new_room = _4_DOOR_ROOM.instantiate()
						get_tree().current_scene.add_child(new_room)
						new_room.global_position = room.global_position + Vector2(384, 0)
						new_room.set_connected_room_left(room)
						rooms += [new_room]
						added_new_room = true
						room.set_connected_room_right(new_room)
	
