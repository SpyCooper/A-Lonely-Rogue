extends Panel

# object references
@onready var icons = $SubViewportContainer/SubViewport/icons
@onready var sub_viewport = $SubViewportContainer/SubViewport
const MAP_ROOM_ICON = preload("res://Scenes/map/mini_map/map_room_icon.tscn")

# variables
var can_move_map = false
var move_map = false
var rooms = []

# on ready
func _ready():
	# hide the map
	hide()
	# when the player enters a room
	Events.room_entered.connect(func(room):
		# do logic on the map
		map_logic(room)
	)

# every frame
func _process(_delta):
	# if the map button is pressed
	if Input.is_action_just_pressed("Map"):
		# toggle the map
		open_or_close()

# on a set interval
func _physics_process(_delta):
	# if the attack button is pressed
	if Input.is_action_pressed("Attack"):
		# if the map can move
		if can_move_map:
			# move the map
			move_map = true
	# if the attack button is released
	elif Input.is_action_just_released("Attack"):
		# if the map was moving
		if move_map:
			# disable map movement
			move_map = false

# on unhandled input
func _input(event):
	# if the move map is active
	if move_map == true:
		# if the event was a move motion
		if event is InputEventMouseMotion:
			# move the map based on the mouse movement (divided by 2 because the camera is at a 2x scale)
			icons.position += (event.relative/2)

# when the reset map button is pressed, reset the map position to be at spawn
func _on_reset_map_button_pressed():
	icons.position = Vector2(0,0)

# does the map logic for the room the player is in
func map_logic(room):
	# finds the relative position for the room on the minimap
	var relative_position = Vector2(room.global_position.x/384*32, room.global_position.y/224*32)
	# finds if the room has spawned and if it has spawned, which room it is
	var has_spawned = false
	var icon_that_matches = null
	for temp_room in rooms:
		# if the room position matches the relative position of the current room
		if temp_room.position == relative_position:
			# the room has spawned the icon that matches is the temp room
			has_spawned = true
			icon_that_matches = temp_room
		# if the room position doesn't matches the relative position of the current room
		else:
			# tell the room the player left it
			temp_room.player_left_room()
	# if the room has not spawned
	if !has_spawned:
		# spawn the room with the relavent data
		var instance = MAP_ROOM_ICON.instantiate()
		icons.add_child(instance)
		instance.position = relative_position
		instance.set_icons(room.get_door_type(), room.get_room_type())
		instance.player_entered_room()
		rooms += [instance]
	# if the room has spawned
	else:
		# tell the room that player is in it
		icon_that_matches.player_entered_room()

# toggle the map
func open_or_close():
	if !visible:
		show()
	else:
		hide()

# when the mouse enters the map area
func _on_mouse_entered():
	# allow the map to move
	can_move_map = true

# when the mouse leaves the map area
func _on_mouse_exited():
	# do not allow the map to move
	can_move_map = false

# when the close button is pressed, toggle the map
func _on_close_button_pressed():
	open_or_close()
