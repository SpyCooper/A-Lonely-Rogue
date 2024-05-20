extends Node2D

@onready var door_up = $DoorVisualUp
@onready var door_right = $DoorVisualRight
@onready var door_down = $DoorVisualDown
@onready var door_left = $DoorVisualLeft

var number_of_enemies = 0

func _ready():
	hide_all_doors()

func _on_player_detector_body_entered(body):
	if body is Player:
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
		if door.is_locked() == false:
			door.hide()

func disable_all_doors():
	disable_door(door_up)
	disable_door(door_right)
	disable_door(door_down)
	disable_door(door_left)

func disable_door(door):
	if door != null:
		if door.is_locked() == false:
			door.hide()
			door.queue_free()

func enable_all_doors():
	enable_door(door_up)
	enable_door(door_right)
	enable_door(door_down)
	enable_door(door_left)

func enable_door(door):
	if door != null:
		if door.is_locked() == false:
			door.show()

#func unlocked_door(door):
	#print(door)
	#if door == door_up:
		#print("door up unlocked")
	#elif door == door_down:
		#print("door down unlocked")
	#elif door == door_left:
		#print("door left unlocked")
	#elif door == door_right:
		#print("door right unlocked")
