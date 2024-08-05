extends AnimatedSprite2D

# defines the mini map room types
enum room_type
{
	boss,
	crystal,
	forge,
	locked,
	none,
}

# object references
@onready var in_room_icon = $in_room_icon

# variables
var type = room_type.none

# resets the icon when the player leaves the room
func player_left_room():
	# resets the icon in the room when the player leaves
	if type == room_type.boss:
		in_room_icon.play("boss")
	elif type == room_type.crystal:
		in_room_icon.play("crystal_boss")
	elif type == room_type.locked:
		in_room_icon.play("locked")
	elif type == room_type.forge:
		in_room_icon.play("forge")
	else:
		in_room_icon.play("none")

# sets the icon to show the player
func player_entered_room():
	in_room_icon.play("player")

# sets the icon for the room and the room itself
func set_icons(doors_in_room : RoomData.door_type, original_room_type : RoomData.room_types):
	# chooses the correct room
	if doors_in_room == RoomData.door_type.four_doors:
		play("4_door")
	elif doors_in_room == RoomData.door_type.three_doors_no_up:
		play("3_door_no_up")
	elif doors_in_room == RoomData.door_type.three_doors_no_down:
		play("3_door_no_down")
	elif doors_in_room == RoomData.door_type.three_doors_no_right:
		play("3_door_no_right")
	elif doors_in_room == RoomData.door_type.three_doors_no_left:
		play("3_door_no_left")
	elif doors_in_room == RoomData.door_type.two_doors_up_right:
		play("2_door_up_right")
	elif doors_in_room == RoomData.door_type.two_doors_up_left:
		play("2_door_up_left")
	elif doors_in_room == RoomData.door_type.two_doors_up_down:
		play("2_door_up_down")
	elif doors_in_room == RoomData.door_type.two_doors_down_right:
		play("2_door_down_right")
	elif doors_in_room == RoomData.door_type.two_doors_down_left:
		play("2_door_down_left")
	elif doors_in_room == RoomData.door_type.two_doors_left_right:
		play("2_door_left_right")
	elif doors_in_room == RoomData.door_type.one_doors_up:
		play("1_door_up")
	elif doors_in_room == RoomData.door_type.one_doors_down:
		play("1_door_down")
	elif doors_in_room == RoomData.door_type.one_doors_left:
		play("1_door_left")
	elif doors_in_room == RoomData.door_type.one_doors_right:
		play("1_door_right")
	
	# chooses the correct in room icon
	if original_room_type == RoomData.room_types.boss:
		type = room_type.boss
		in_room_icon.play("boss")
	elif original_room_type == RoomData.room_types.crystal_boss:
		type = room_type.crystal
		in_room_icon.play("crystal_boss")
	elif original_room_type == RoomData.room_types.locked_item:
		type = room_type.locked
		in_room_icon.play("locked")
	elif original_room_type == RoomData.room_types.forge:
		type = room_type.forge
		in_room_icon.play("forge")
	else:
		type = room_type.none
		in_room_icon.play("none")
