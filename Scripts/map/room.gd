extends Node2D

# references to the door visuals
@onready var door_up = $DoorVisualUp
@onready var door_right = $DoorVisualRight
@onready var door_down = $DoorVisualDown
@onready var door_left = $DoorVisualLeft
@onready var door_sound = $door_sound

# sets up the number of enemies
var number_of_enemies = 0
var enemies_spawned = []

# hide the doors on start
func _ready():
	hide_all_doors()

# when a body enters the player_detector
func _on_player_detector_body_entered(body):
	# if the body is the player
	if body is Player:
		# emit the signal room_entered
		Events.room_entered.emit(self)
		# if there are no enemies in the room
		if number_of_enemies == 0:
			# disable the doors
			disable_all_doors()
			# lets the player know they entered a room
			Events.player.room_entered()
		# if there are enemies in the room
		elif number_of_enemies > 0:
			# enable the doors
			enable_all_doors()
			# wake_up each enemy
			for enemy in enemies_spawned:
				enemy.wake_up()

# when an body enters
func _on_enemy_detector_body_entered(body):
	# if the body is an enemy
	if body is Enemy:
		# adds an enemy to the count and a refernce to the enemy
		number_of_enemies += 1
		enemies_spawned += [body]

# when a body exits the enemy detector
func _on_enemy_detector_body_exited(body):
	# if the body is an enemy
	if body is Enemy:
		# remove a enemy from the count
		number_of_enemies -= 1
		enemies_spawned.remove_at(enemies_spawned.find(body))
		# if all enemies are gone, disable the doors
		if number_of_enemies == 0 && enemies_spawned.size() == 0:
			disable_all_doors()

# hide all doors
func hide_all_doors():
	hide_door(door_up)
	hide_door(door_right)
	hide_door(door_down)
	hide_door(door_left)

# hide the door
func hide_door(door):
	if door != null:
		if door.is_locked() == false:
			door.hide()

# disable all doors
func disable_all_doors():
	disable_door(door_up)
	disable_door(door_right)
	disable_door(door_down)
	disable_door(door_left)

# remove a door if it exists and unlocked
func disable_door(door):
	if door != null:
		# if the door is unlocked
		if door.is_locked() == false:
			door.hide()
			door.queue_free()

# enable all doors
func enable_all_doors():
	enable_door(door_up)
	enable_door(door_right)
	enable_door(door_down)
	enable_door(door_left)

# enable a door if it exists
func enable_door(door):
	if door != null:
		if door.is_locked() == false:
			door.show()

# unlock a door
func unlocked_door(door):
	if door == door_up:
		disable_door(door_up)
	elif door == door_down:
		disable_door(door_down)
	elif door == door_left:
		disable_door(door_left)
	elif door == door_right:
		disable_door(door_right)

# if there are enemies in the room, return true
func is_enemies():
	if number_of_enemies > 0:
		return true
	else:
		return false

func get_enemies_in_room():
	return enemies_spawned
