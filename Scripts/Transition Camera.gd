extends Camera2D

# on start
func _ready() -> void:
	# when the room_entered signal is sent
	Events.room_entered.connect(func(room):
		# move the camera to the new room
		global_position = room.global_position
	)
