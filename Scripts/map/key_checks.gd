extends Node2D

# gets references to the door visuals for the room
@onready var door_visual_up = $"../DoorVisualUp"
@onready var door_visual_right = $"../DoorVisualRight"
@onready var door_visual_down = $"../DoorVisualDown"
@onready var door_visual_left = $"../DoorVisualLeft"

# gets references to the key sprites on the floor for the room
@onready var up_key_sprite = $Key_check_up/AnimatedSprite2D
@onready var down_key_sprite = $Key_check_down/AnimatedSprite2D
@onready var left_key_sprite = $Key_check_left/AnimatedSprite2D
@onready var right_key_sprite = $Key_check_right/AnimatedSprite2D

# sets the lock door variables
var door_up_locked = false
var door_down_locked = false
var door_left_locked = false
var door_right_locked = false

# on start
func _ready():
	# if the door visual exists, the lock status is set to the door locked status
	if door_visual_up != null:
		door_up_locked = door_visual_up.is_locked()
	if door_visual_down != null:
		door_down_locked = door_visual_down.is_locked()
	if door_visual_left != null:
		door_left_locked = door_visual_left.is_locked()
	if door_visual_right != null:
		door_right_locked = door_visual_right.is_locked()
	# resets the floor key sprites
	reset_key_sprites()

# if the player enters the key_check area when all enemies are dead
func _on_key_check_up_body_entered(body):
	if door_visual_up != null:
		if get_parent().is_enemies() == false:
			if body is Player:
				# if the door is locked
				if door_up_locked == true:
					# if the player uses a key
					if body.use_key():
						# unlock the door and the remove the floor sprite
						door_visual_up.unlock()
						door_up_locked = false
						reset_key_sprites()
						get_parent().unlocked_door(door_visual_up)

# if the player enters the key_check area when all enemies are dead
func _on_key_check_down_body_entered(body):
	if door_visual_down != null:
		if get_parent().is_enemies() == false:
			if body is Player:
				# if the door is locked
				if door_down_locked == true:
					# if the player uses a key
					if body.use_key():
						# unlock the door and the remove the floor sprite
						door_visual_down.unlock()
						door_down_locked = false
						reset_key_sprites()
						get_parent().unlocked_door(door_visual_down)

# if the player enters the key_check area when all enemies are dead
func _on_key_check_left_body_entered(body):
	if door_visual_left != null:
		if get_parent().is_enemies() == false:
			if body is Player:
				# if the door is locked
				if door_left_locked == true:
					# if the player uses a key
					if body.use_key():
						# unlock the door and the remove the floor sprite
						door_visual_left.unlock()
						door_left_locked = false
						reset_key_sprites()
						get_parent().unlocked_door(door_visual_left)

# if the player enters the key_check area when all enemies are dead
func _on_key_check_right_body_entered(body):
	if door_visual_right != null:
		if get_parent().is_enemies() == false:
			if body is Player:
				# if the door is locked
				if door_right_locked == true:
					# if the player uses a key
					if body.use_key():
						# unlock the door and the remove the floor sprite
						door_visual_right.unlock()
						door_right_locked = false
						reset_key_sprites()
						get_parent().unlocked_door(door_visual_right)

# resets the key sprites on the floor if the door is unlocked
func reset_key_sprites():
	if door_up_locked == false:
		up_key_sprite.hide()
	if door_down_locked == false:
		down_key_sprite.hide()
	if door_left_locked == false:
		left_key_sprite.hide()
	if door_right_locked == false:
		right_key_sprite.hide()
