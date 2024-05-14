extends Camera2D

@onready var hud = %HUD
var hud_start_position : Vector2

func _ready() -> void:
	hud_start_position = hud.position
	
	Events.room_entered.connect(func(room):
		global_position = room.global_position
		hud.position = global_position + hud_start_position
	)
