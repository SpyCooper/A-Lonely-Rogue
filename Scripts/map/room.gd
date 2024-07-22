extends Node2D

# references to the door visuals
@onready var door_sound = $door_sound
@onready var top_door = $top_door
@onready var bottom_door = $bottom_door
@onready var left_door = $left_door
@onready var right_door = $right_door
@onready var key_checks = $key_checks

# sets up the number of enemies
var enemies_spawned = []
var can_play_sound = false

#func _ready():
	## set if the doors are locked, etc
	#top_door.lock()

# when a body enters the player_detector
func _on_player_detector_body_entered(body):
	# if the body is the player
	if body is Player:
		# emit the signal room_entered
		Events.room_entered.emit(self)
		# if there are no enemies in the room
		if enemies_spawned.size() == 0:
			# disable the doors
			disable_all_doors()
			# lets the player know they entered a room
			Events.player.room_entered(self)
			# check the lock status when the player enters the room and there are no enemies
			if Events.player.has_keys():
				key_checks.locks_changed(true)
			else:
				key_checks.locks_changed(false)
		# if there are enemies in the room
		elif enemies_spawned.size() > 0:
			# enable the doors
			close_all_doors()
			# wake_up each enemy
			for enemy in enemies_spawned:
				enemy.wake_up()
			# check the lock status when the player enters the room
			key_checks.locks_changed(false)
			# lets the player know the room has enemies
			Events.player.room_has_enemies()

# when an body enters
func _on_enemy_detector_body_entered(body):
	# if the body is an enemy
	if body is Enemy:
		# adds an enemy to the count and a refernce to the enemy
		enemies_spawned = enemies_spawned + [body]

# when a body exits the enemy detector
func _on_enemy_detector_body_exited(body):
	# if the body is an enemy
	if body is Enemy:
		if enemies_spawned[enemies_spawned.find(body)].dying:
			# remove a enemy from the count
			enemies_spawned.remove_at(enemies_spawned.find(body))
			# if all enemies are gone, disable the doors
			if enemies_spawned.size() == 0:
				open_all_doors()
				# check the lock status when the player enters the room and there are no enemies
				if Events.player.has_keys():
					key_checks.locks_changed(true)
				else:
					key_checks.locks_changed(false)

# closes all doors
func close_all_doors():
	if top_door != null:
		top_door.close_door()
	if bottom_door != null:
		bottom_door.close_door()
	if left_door != null:
		left_door.close_door()
	if right_door != null:
		right_door.close_door()
	# plays the door sound
	door_sound.play()

# opens all doors
func open_all_doors():
	if top_door != null:
		top_door.open_door()
	if bottom_door != null:
		bottom_door.open_door()
	if left_door != null:
		left_door.open_door()
	if right_door != null:
		right_door.open_door()
	# plays the door sound
	door_sound.play()
	
	Events.player.room_cleared()

# disables all doors
func disable_all_doors():
	if top_door != null:
		top_door.disable_door()
	if bottom_door != null:
		bottom_door.disable_door()
	if left_door != null:
		left_door.disable_door()
	if right_door != null:
		right_door.disable_door()

# unlock a specific door
func unlock_door(door):
	if door == top_door:
		if top_door != null:
			top_door.open_door()
	elif door == bottom_door:
		if bottom_door != null:
			bottom_door.open_door()
	elif door == left_door:
		if left_door != null:
			left_door.open_door()
	elif door == right_door:
		if right_door != null:
			right_door.open_door()
	# plays the door sound
	door_sound.play()

# if there are enemies in the room, return true
func is_enemies():
	if enemies_spawned.size() > 0:
		return true
	else:
		return false

func get_enemies_in_room():
	return enemies_spawned

# when the player obtains a key, reset the locks icons
func player_obtained_keys():
	key_checks.locks_changed(true)

func enemy_spawned_in_room():
	# enable the doors
	close_all_doors()
	# check the lock status when the player enters the room
	key_checks.locks_changed(false)
	Events.player.room_has_enemies()

func cleared():
	enemies_spawned = []
	open_all_doors()
