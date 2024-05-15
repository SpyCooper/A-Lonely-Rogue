extends Node2D

@onready var door_up = $DoorVisualUp
@onready var door_right = $DoorVisualRight
@onready var door_down = $DoorVisualDown
@onready var door_left = $DoorVisualLeft

var number_of_enemies = 0

func _ready():
	hide_all_doors()

func _on_player_detector_body_entered(body):
	if body.has_method("player_take_damage") == true:
		Events.room_entered.emit(self)
		if number_of_enemies == 0:
			disable_all_doors()
		elif number_of_enemies > 0:
			enable_all_doors()

func _on_enemy_detector_body_entered(body):
	number_of_enemies += 1

func _on_enemy_detector_body_exited(body):
	number_of_enemies -= 1
	if number_of_enemies == 0:
		disable_all_doors()

func hide_all_doors():
	hide_door(door_up)
	hide_door(door_right)
	hide_door(door_down)
	hide_door(door_left)

func hide_door(door):
	if door != null:
		door.hide()

func disable_all_doors():
	disable_door(door_up)
	disable_door(door_right)
	disable_door(door_down)
	disable_door(door_left)

func disable_door(door):
	if door != null:
		door.hide()
		door.queue_free()

func enable_all_doors():
	enable_door(door_up)
	enable_door(door_right)
	enable_door(door_down)
	enable_door(door_left)

func enable_door(door):
	if door != null:
		door.show()
