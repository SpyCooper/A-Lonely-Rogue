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
	
	## TEMP
	
	var top_room = _4_DOOR_ROOM.instantiate()
	top_room.global_position = Vector2(0, -224)
	get_tree().current_scene.add_child(top_room)
	rooms += [top_room]
	top_room.set_connected_room_bottom(starting_room)
	
	var bottom_room = _4_DOOR_ROOM.instantiate()
	bottom_room.global_position = Vector2(0, 224)
	get_tree().current_scene.add_child(bottom_room)
	rooms += [bottom_room]
	bottom_room.set_connected_room_top(starting_room)
	
	var left_room = _4_DOOR_ROOM.instantiate()
	left_room.global_position = Vector2(-384, 0)
	get_tree().current_scene.add_child(left_room)
	rooms += [left_room]
	left_room.set_connected_room_right(starting_room)
	
	var right_room = _4_DOOR_ROOM.instantiate()
	right_room.global_position = Vector2(384, 0)
	get_tree().current_scene.add_child(right_room)
	rooms += [right_room]
	right_room.set_connected_room_left(starting_room)
	
	starting_room.set_connected_room_top(top_room)
	starting_room.set_connected_room_bottom(bottom_room)
	starting_room.set_connected_room_left(left_room)
	starting_room.set_connected_room_right(right_room)
	
	### END TEMP
	
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
						if room.has_door_top() && !room.has_connection_top():
							var new_room
							var target_room_position = room.global_position + Vector2(0, -224)
							
							if get_room_at_position(target_room_position) == null:
								#var random_room = rng.randi_range(0,3)
								#if random_room == 2:
									#new_room = _4_DOOR_ROOM.instantiate()
								
								var top_connection = get_connection_top(target_room_position)
								var left_connection = get_connection_left(target_room_position)
								var right_connection = get_connection_right(target_room_position)
								
								if top_connection != null && right_connection != null && left_connection != null:
									new_room = _4_DOOR_ROOM.instantiate()
								elif top_connection != null && right_connection != null && left_connection == null:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								elif top_connection != null && right_connection == null && left_connection != null:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								elif top_connection == null && right_connection != null && left_connection != null:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								elif top_connection != null && right_connection == null && left_connection == null:
									new_room = _2_DOOR_UP_DOWN.instantiate()
								elif top_connection == null && right_connection != null && left_connection == null:
									new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif top_connection == null && right_connection == null && left_connection != null:
									new_room = _2_DOOR_DOWN_LEFT.instantiate()
								else:
									new_room = _1_DOOR_ROOM_DOWN.instantiate()
								# basic idea (this crashes)
								#var random_room = rng.randi_range(0,rooms_that_can_connect_to_top.size())
								#var new_room = rooms_that_can_connect_to_top[random_room].instantiate()
								
								get_tree().current_scene.add_child(new_room)
								new_room.global_position = target_room_position
								new_room.set_connected_room_top(top_connection)
								new_room.set_connected_room_bottom(room)
								new_room.set_connected_room_left(left_connection)
								new_room.set_connected_room_right(right_connection)
								rooms += [new_room]
								added_new_room = true
								room.set_connected_room_top(new_room)
					# add a room to the bottom of the current room
					elif iteration == 2:
						if room.has_door_bottom() && !room.has_connection_bottom():
							var new_room
							var target_room_position = room.global_position + Vector2(0, 224)
							
							if get_room_at_position(target_room_position) == null:
								#var random_room = rng.randi_range(0,3)
								#if random_room == 2:
									#new_room = _4_DOOR_ROOM.instantiate()
								
								var bottom_connection = get_connection_bottom(target_room_position)
								var left_connection = get_connection_left(target_room_position)
								var right_connection = get_connection_right(target_room_position)
								
								if bottom_connection != null && right_connection != null && left_connection != null:
									new_room = _4_DOOR_ROOM.instantiate()
								elif bottom_connection != null && right_connection != null && left_connection == null:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								elif bottom_connection != null && right_connection == null && left_connection != null:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								elif bottom_connection == null && right_connection != null && left_connection != null:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								elif bottom_connection != null && right_connection == null && left_connection == null:
									new_room = _2_DOOR_UP_DOWN.instantiate()
								elif bottom_connection == null && right_connection != null && left_connection == null:
									new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif bottom_connection == null && right_connection == null && left_connection != null:
									new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								else:
									new_room = _1_DOOR_ROOM_UP.instantiate()
								
								get_tree().current_scene.add_child(new_room)
								new_room.global_position = target_room_position
								new_room.set_connected_room_top(room)
								new_room.set_connected_room_bottom(bottom_connection)
								new_room.set_connected_room_left(left_connection)
								new_room.set_connected_room_right(right_connection)
								rooms += [new_room]
								added_new_room = true
								room.set_connected_room_bottom(new_room)
					# add a room to the left of the current room
					elif iteration == 3:
						if room.has_door_left() && !room.has_connection_left():
							var new_room
							var target_room_position = room.global_position + Vector2(-384, 0)
							
							if get_room_at_position(target_room_position) == null:
								#var random_room = rng.randi_range(0,3)
								#if random_room == 2:
									#new_room = _4_DOOR_ROOM.instantiate()
								
								var top_connection = get_connection_top(target_room_position)
								var bottom_connection = get_connection_bottom(target_room_position)
								var left_connection = get_connection_left(target_room_position)
								
								#print(top_connection)
								#print(bottom_connection)
								#print(left_connection)
								
								if top_connection != null && bottom_connection != null && left_connection != null:
									new_room = _4_DOOR_ROOM.instantiate()
								elif top_connection != null && bottom_connection != null && left_connection == null:
									new_room = _3_DOOR_ROOM_NO_LEFT.instantiate()
								elif top_connection != null && bottom_connection == null && left_connection != null:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								elif top_connection == null && bottom_connection != null && left_connection != null:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								elif top_connection != null && bottom_connection == null && left_connection == null:
									new_room = _2_DOOR_ROOM_UP_RIGHT.instantiate()
								elif top_connection == null && bottom_connection != null && left_connection == null:
									new_room = _2_DOOR_DOWN_RIGHT.instantiate()
								elif top_connection == null && bottom_connection == null && left_connection != null:
									new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								else:
									new_room = _1_DOOR_ROOM_RIGHT.instantiate()
								
								get_tree().current_scene.add_child(new_room)
								new_room.global_position = target_room_position
								new_room.set_connected_room_top(top_connection)
								new_room.set_connected_room_bottom(bottom_connection)
								new_room.set_connected_room_left(left_connection)
								new_room.set_connected_room_right(room)
								rooms += [new_room]
								added_new_room = true
								room.set_connected_room_left(new_room)
					# add a room to the right of the current room
					elif iteration == 4:
						if room.has_door_right() && !room.has_connection_right():
							var new_room
							var target_room_position = room.global_position + Vector2(384, 0)
							
							if get_room_at_position(target_room_position) == null:
								#var random_room = rng.randi_range(0,3)
								#if random_room == 2:
									#new_room = _4_DOOR_ROOM.instantiate()
								
								var top_connection = get_connection_top(target_room_position)
								var bottom_connection = get_connection_bottom(target_room_position)
								var right_connection = get_connection_right(target_room_position)
								
								if top_connection != null && bottom_connection != null && right_connection != null:
									new_room = _4_DOOR_ROOM.instantiate()
								elif top_connection != null && bottom_connection != null && right_connection == null:
									new_room = _3_DOOR_ROOM_NO_RIGHT.instantiate()
								elif top_connection != null && bottom_connection == null && right_connection != null:
									new_room = _3_DOOR_ROOM_NO_DOWN.instantiate()
								elif top_connection == null && bottom_connection != null && right_connection != null:
									new_room = _3_DOOR_ROOM_NO_UP.instantiate()
								elif top_connection != null && bottom_connection == null && right_connection == null:
									new_room = _2_DOOR_ROOM_UP_LEFT.instantiate()
								elif top_connection == null && bottom_connection != null && right_connection == null:
									new_room = _2_DOOR_DOWN_LEFT.instantiate()
								elif top_connection == null && bottom_connection == null && right_connection != null:
									new_room = _2_DOOR_LEFT_RIGHT.instantiate()
								elif top_connection == null && bottom_connection == null && right_connection == null:
									new_room = _1_DOOR_ROOM_LEFT.instantiate()
								
								get_tree().current_scene.add_child(new_room)
								new_room.global_position = target_room_position
								new_room.set_connected_room_top(top_connection)
								new_room.set_connected_room_bottom(bottom_connection)
								new_room.set_connected_room_left(room)
								new_room.set_connected_room_right(right_connection)
								rooms += [new_room]
								added_new_room = true
								room.set_connected_room_right(new_room)

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
				#print("room overlapping at " + str(room_location))
				return adj_room
	return null
