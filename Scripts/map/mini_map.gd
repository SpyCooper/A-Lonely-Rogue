extends ColorRect

@onready var icons = $SubViewportContainer/SubViewport/icons
@onready var sub_viewport = $SubViewportContainer/SubViewport
const MAP_ROOM_ICON = preload("res://Scenes/map/mini_map/map_room_icon.tscn")

var can_move_map = false
var move_map = false
var rooms = []
var size_x = 810/2
var size_y = 540/2

func _ready():
	Events.room_entered.connect(func(room):
		map_logic(room)
	)
	
	hide()

func _process(_delta):
	if Input.is_action_just_pressed("Map"):
		open_or_close()

func _physics_process(_delta):
	if Input.is_action_pressed("Attack"):
		if can_move_map:
			move_map = true
	elif Input.is_action_just_released("Attack"):
		if move_map:
			move_map = false

func _input(event):
	if move_map == true:
		if event is InputEventMouseMotion:
			icons.position += (event.relative/2)

func _on_reset_map_button_pressed():
	icons.position = Vector2(0,0)

func map_logic(room):
	var relative_position = Vector2(room.global_position.x/384*32, room.global_position.y/224*32)
	var has_spawned = false
	var icon_that_matches = null
	for temp_room in rooms:
		if temp_room.position == relative_position:
			has_spawned = true
			icon_that_matches = temp_room
		else:
			temp_room.player_left_room()
	if !has_spawned:
		var instance = MAP_ROOM_ICON.instantiate()
		icons.add_child(instance)
		instance.position = relative_position
		instance.set_icons(room.get_door_type(), room.get_room_type())
		instance.player_entered_room()
		rooms += [instance]
	else:
		icon_that_matches.player_entered_room()

func open_or_close():
	if !visible:
		show()
	else:
		hide()

func _on_mouse_entered():
	can_move_map = true

func _on_mouse_exited():
	can_move_map = false

func _on_close_button_pressed():
	open_or_close()
