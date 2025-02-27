extends CharacterBody2D

class_name Enemy

# defines the look_direction enum
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
var spawning = true
var dying = false
var attacks_that_hit = []

# status effect variables
var poisoned = false
var shadow_flamed = false
var dusted = false
var dusted_slow = 0.35
var dusted_stack = 0
var player_in_damage_area = false

# object references
var player
var catalog
@onready var hitbox = $hitbox

# defines a basic reay function for all enemies
## NOTE: ALL ENEMIES NEED TO HAVE THEIR OWN READY FUNCTION
func _ready():
	sleep()
	player = Events.player
	catalog = Events.catalog
	max_health = health
	
	## shouldn't need this because all enemies are woken up by enemy_detector in rooms
	Events.room_entered.connect(func(room):
		if room == get_parent():
			wake_up()
			spawning = false
		else:
			sleep()
	)

# defines basic sleep function for enemies
## NOTE: ENEMIES MAY NEED TO HAVE THEIR OWN SLEEP FUNCTION
func sleep():
	player_in_room = false

# defines basic wake up function
## NOTE: ENEMIES MAY NEED TO HAVE THEIR OWN WAKE_UP FUNCTION
func wake_up():
	player_in_room = true

# runs when a knife (or other weapon) hits the enemy
## NOTE: this can change between enemies
func take_damage(damage, attack_identifer, is_effect):
	var attack_can_hit = true
	#if the damage is not an effect
	if is_effect == false:
		# checks if an attack with the identifier has hit
		for identifier in attacks_that_hit:
			if identifier == attack_identifer:
				attack_can_hit = false
	# checks if the enemy is spawning or dying
	if spawning || dying:
		attack_can_hit = false
	# if the attack can hit
	if attack_can_hit:
		# deal damage
		health -= damage
		# add the damage to the player's stats
		PlayerData.damage_dealt += damage
		# if health <= 0 kills the enemy
		if health <= 0:
			enemy_slain()

# defines a basic enemy slain function
## NOTE: this can change between enemies for animations
func enemy_slain():
	player.killed_enemy()
	despawn()

# returns the most important direction based on the target location
# mainly used for animations for bosses
# target_pos is usually going to be the player position
func get_look_direction(target_pos):
	if target_pos.x > 0 && abs(target_pos.x) > abs(target_pos.y):
		return look_direction.right
	elif target_pos.x < 0 && abs(target_pos.x) > abs(target_pos.y):
		return look_direction.left
	elif target_pos.y > 0 && abs(target_pos.x) < abs(target_pos.y):
		return look_direction.down
	elif target_pos.y < 0 && abs(target_pos.x) < abs(target_pos.y):
		return look_direction.up
	else: 
		return look_direction.right

# returns the most important left or right direction based on the target location
# used for slimes or other enemies that do not need 4 way look direction
# target_pos is usually going to be the player position
func get_left_right_look_direction(target_pos):
	if target_pos.x > 0:
		return look_direction.right
	elif target_pos.x < 0:
		return look_direction.left
	else:
		return look_direction.right

# returns if the enemy is poisoned
func is_poisoned():
	return poisoned

# toggles the enemy's poisoned state
func toggle_poisoned():
	if poisoned == false:
		poisoned = true;
	else:
		poisoned = false

# returns if the enemy is has shadow_flame effect on them
func is_shadow_flamed():
	return shadow_flamed

# toggles the enemy's shadow_flame effect state
func toggle_shadow_flamed():
	if shadow_flamed == false:
		shadow_flamed = true;
	else:
		shadow_flamed = false

# returns if the enemy is has dust_blade effect on them
func is_dusted():
	return dusted

# sets the enemies dusted effect
# this effect stacks
func set_dusted_status(status):
	if status == true:
		dusted_stack += 1
		dusted = true
	else:
		dusted_stack -= 1
	# if all dusted stacks are gone, the enemy is no longer dusted
	if dusted_stack == 0:
		dusted = false

# returns the speed of the enemy
func get_speed():
	# checks if the enemy is dusted or not
	if dusted:
		# if the enemy is dusted, it adjust speed based on dusted's slow effect
		return speed * (1-dusted_slow)
	else:
		return speed

# defines a get_animated_sprite() that each enemy can implement
func get_animated_sprite():
	pass

# used to spawn enemies in the room and allows them to move right away
func spawned_in_room():
	# this is not called on enemies that extend other enemies (ex: greenslime does not inherit enemy since it extends slime)
	print(self)
	Events.current_room.add_enemy_to_room(self)
	player_in_room = true

# despawns the enemy
func despawn():
	Events.current_room.remove_enemy_from_room(self)
	queue_free()

# despawns the enemy without calling the room
func despawn_without_calling_current_room():
	queue_free()

# returns if the enemy is currently going through a spawn animation
func is_spawning():
	return spawning

# returns if the enemy is currently going through a death animation
func is_dying():
	return dying

# removes the enemy's hitbox
func remove_hitbox():
	hitbox.queue_free()
