extends CharacterBody2D

class_name Enemy

enum look_direction
{
	right,
	left,
	up,
	down
}

# variables
var speed
var player_position
var health
var max_health
var player_in_room = false
var spawning = false

# checks status effects
var poisoned = false
var shadow_flamed = false
var dusted = false
var dusted_slow = 0.35
var dusted_stack = 0

# object references
var player

func _ready():
	sleep()
	player = Events.player
	max_health = health
	Events.room_entered.connect(func(room):
		if room == get_parent():
			wake_up()
		else:
			sleep()
	)

func get_spawning():
	return spawning
	
func sleep():
	player_in_room = false

func wake_up():
	player_in_room = true

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	health -= damage
	if health <= 0:
		enemy_slain()

func enemy_slain():
	player.killed_enemy()
	queue_free()

func get_look_direction(target_pos):
	if target_pos.x > 0 && abs(target_pos.x) > abs(target_pos.y):
		return look_direction.right
	elif target_pos.x < 0 && abs(target_pos.x) > abs(target_pos.y):
		return look_direction.left
	elif target_pos.y > 0 && abs(target_pos.x) < abs(target_pos.y):
		return look_direction.down
	elif target_pos.y < 0 && abs(target_pos.x) < abs(target_pos.y):
		return look_direction.up

func get_left_right_look_direction(target_pos):
	if target_pos.x > 0:
		return look_direction.right
	elif target_pos.x < 0:
		return look_direction.left

func is_poisoned():
	return poisoned

func toggle_poisoned():
	if poisoned == false:
		poisoned = true;
	else:
		poisoned = false

func is_shadow_flamed():
	return shadow_flamed

func toggle_shadow_flamed():
	if shadow_flamed == false:
		shadow_flamed = true;
	else:
		shadow_flamed = false

func is_dusted():
	return dusted

func set_dusted_status(status):
	if status == true:
		dusted_stack += 1
		dusted = true
	else:
		dusted_stack -= 1
	if dusted_stack == 0:
		dusted = false

func get_speed():
	if dusted:
		return speed * (1-dusted_slow)
	else:
		return speed

func get_animated_sprite():
	pass

func spawned_in_room():
	player_in_room = true

func despawn():
	queue_free()
