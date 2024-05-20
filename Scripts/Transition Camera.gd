extends Camera2D

#@onready var hud = %HUD
var hud_start_position : Vector2

func _ready() -> void:
	Events.room_entered.connect(func(room):
		global_position = room.global_position
	)
