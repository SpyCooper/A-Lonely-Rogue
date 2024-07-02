extends Node2D

# gets references to the door visuals for the room
@onready var top_door = $"../top_door"
@onready var bottom_door = $"../bottom_door"
@onready var left_door = $"../left_door"
@onready var right_door = $"../right_door"

# gets references to the key sprites on the floor for the room
@onready var up_key_sprite = $Key_check_up/AnimatedSprite2D
@onready var down_key_sprite = $Key_check_down/AnimatedSprite2D
@onready var left_key_sprite = $Key_check_left/AnimatedSprite2D
@onready var right_key_sprite = $Key_check_right/AnimatedSprite2D

# sets the lock door variables
var top_door_locked = false
var bottom_door_locked = false
var left_door_locked = false
var right_door_locked = false

# on start
func _ready():
	locks_changed()

# if the player enters the key_check area when all enemies are dead
func _on_key_check_up_body_entered(body):
	if top_door != null:
		if get_parent().is_enemies() == false:
			if body is Player:
				# if the door is locked
				if top_door_locked == true:
					# if the player uses a key
					if body.use_key():
						# unlock the door
						top_door.unlock()
						top_door_locked = false
						get_parent().unlock_door(top_door)
						# update the key sprites
						reset_key_sprites()

# if the player enters the key_check area when all enemies are dead
func _on_key_check_down_body_entered(body):
	if bottom_door != null:
		if get_parent().is_enemies() == false:
			if body is Player:
				# if the door is locked
				if bottom_door_locked == true:
					# if the player uses a key
					if body.use_key():
						# unlock the door
						bottom_door.unlock()
						bottom_door_locked = false
						get_parent().unlock_door(bottom_door)
						# update the key sprites
						reset_key_sprites()

# if the player enters the key_check area when all enemies are dead
func _on_key_check_left_body_entered(body):
	if left_door != null:
		if get_parent().is_enemies() == false:
			if body is Player:
				# if the door is locked
				if left_door_locked == true:
					# if the player uses a key
					if body.use_key():
						# unlock the door
						left_door.unlock()
						left_door_locked = false
						get_parent().unlock_door(left_door)
						# update the key sprites
						reset_key_sprites()

# if the player enters the key_check area when all enemies are dead
func _on_key_check_right_body_entered(body):
	if right_door != null:
		if get_parent().is_enemies() == false:
			if body is Player:
				# if the door is locked
				if right_door_locked == true:
					# if the player uses a key
					if body.use_key():
						# unlock the door
						right_door.unlock()
						right_door_locked = false
						get_parent().unlock_door(right_door)
						# update the key sprites
						reset_key_sprites()

# checks if the locks status is changed
func locks_changed(can_use_keys = false):
	# if the door visual exists, the lock status is set to the door locked status
	if top_door != null:
		top_door_locked = top_door.is_locked()
	if bottom_door != null:
		bottom_door_locked = bottom_door.is_locked()
	if left_door != null:
		left_door_locked = left_door.is_locked()
	if right_door != null:
		right_door_locked = right_door.is_locked()
	# resets the floor key sprites
	reset_key_sprites(can_use_keys)

# resets the key sprites on the floor if the door is unlocked
func reset_key_sprites(key_can_be_used = false):
	# if the door is not locked
	if top_door_locked == false:
		# play the nothing sprite
		up_key_sprite.play("none")
	else:
		# if the door is locked and a key can be used
		if key_can_be_used:
			# play the pulsing animated sprite
			up_key_sprite.play("pulsing")
		# if the door is locked and a key can't be used
		else:
			# play the pulsing animated sprite
			up_key_sprite.play("non_pulsing")
	if bottom_door_locked == false:
		down_key_sprite.play("none")
	else:
		if key_can_be_used:
			down_key_sprite.play("pulsing")
		else:
			down_key_sprite.play("default")
	if left_door_locked == false:
		left_key_sprite.play("none")
	else:
		if key_can_be_used:
			left_key_sprite.play("pulsing")
		else:
			left_key_sprite.play("default")
	if right_door_locked == false:
		right_key_sprite.play("none")
	else:
		if key_can_be_used:
			right_key_sprite.play("pulsing")
		else:
			right_key_sprite.play("default")
