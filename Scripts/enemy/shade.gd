extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_timer = $death_timer
@onready var death_sound = $DeathSound
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_timer = $Spawn_timer

# attack variables
var can_attack = false
var can_attack_timer_max = 7
var can_attack_timer = can_attack_timer_max
var attacking = false
@onready var attack_sound = $attack_sound
@onready var shadow_bolt_attack_timer = $shadow_bolt_attack_timer
@onready var shadow_bolt_spawn_timer = $shadow_bolt_spawn_timer
@onready var shadow_bolt_spawn_left = $shadow_bolt_spawn_left
@onready var shadow_bolt_spawn_right = $shadow_bolt_spawn_right
var max_spawn_in_burst = 3
var spawned_in_current_burst = 0
@onready var time_between_shadow_bolts_burst = $time_between_shadow_bolts_burst
const SHADOW_BOLT = preload("res://Scenes/enemies/shadow_bolt/shadow_bolt.tscn")

# general enemy variables
var target_position
var current_direction : look_direction

# variables
var can_move = true
var playing_hit_animation = false
var is_idle = false

# sets the enemy's stats and references
func _ready():
	speed = 0.85
	health = 15
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog

# when the enemy wakes up
func wake_up():
	# player is now in the room
	player_in_room = true
	# the spawn animation is played
	animated_sprite.play("spawning")
	# the spawn_timer is started
	spawn_timer.start()
	# the spawn sound in played
	spawn_sound.play()

## on every frame
func _process(delta):
	if player_in_room:
		# if the enemy cannot attack
		if !can_attack:
			# decrement the attack timer
			can_attack_timer -= delta
			# if the cant attack timer is less than or equal to 0
			if can_attack_timer <= 0:
				# allow the enemy to attack
				can_attack = true

# called every frame
func _physics_process(_delta):
	# if the player is in the room, the shade isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# if the shade can attack and is further than 30 pixels
			if can_attack == true && position.distance_to(player_position) > 30:
				attack()
			# else if the shade can move
			elif can_move:
				# look in the direction of the player
				# flips the direction of the shade based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					# if any of the hit animations are playing
					if animated_sprite.animation == "hit_move_right":
						# switch to the same frame of the hit animation in the new direction
						# this keeps hit animations running for the same duration
						var frame = animated_sprite.frame
						animated_sprite.play("hit_move_left")
						animated_sprite.frame = frame
					# if a hit animation is not actively playing a hit animation
					elif playing_hit_animation != true || animated_sprite.is_playing() == false:
						# plays the basic move animation and sets the playing_hit_animation to false
						animated_sprite.play("move_left")
						playing_hit_animation = false
						is_idle = false
				## Move right
				elif current_direction == look_direction.right:
					if animated_sprite.animation == "hit_move_left":
						var frame = animated_sprite.frame
						animated_sprite.play("hit_move_right")
						animated_sprite.frame = frame
					elif playing_hit_animation != true || animated_sprite.is_playing() == false:
						animated_sprite.play("move_right")
						playing_hit_animation = false
						is_idle = false
				if position.distance_to(player_position) > 8:
					## has to use get_speed() to move based on dusted effect
					move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
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
		# adds the attack to the attacks that have hit
		attacks_that_hit += [attack_identifer]
		# subtracts the health
		health -= damage
		# if health is greater than 0
		if health > 0:
			# play the hit animation based on the look direction
			if current_direction == look_direction.left:
				if attacking:
					if animated_sprite.is_playing() == false:
						animated_sprite.play("hit_idle_left")
					elif animated_sprite.animation == "shadow_bolt_left_end":
						var frame = animated_sprite.frame
						animated_sprite.play("hit_shadow_bolt_left_end")
						animated_sprite.frame = frame
					elif animated_sprite.animation == "shadow_bolt_left_start":
						var frame = animated_sprite.frame
						animated_sprite.play("hit_shadow_bolt_left_end")
						animated_sprite.frame = frame
				else:
					var frame = animated_sprite.frame
					animated_sprite.frame = frame
					animated_sprite.play("hit_move_left")
			elif current_direction == look_direction.right:
				if attacking:
					if animated_sprite.is_playing() == false:
						animated_sprite.play("hit_idle_right")
					elif animated_sprite.animation == "shadow_bolt_right_end":
						var frame = animated_sprite.frame
						animated_sprite.play("hit_shadow_bolt_right_end")
						animated_sprite.frame = frame
					elif animated_sprite.animation == "shadow_bolt_right_start":
						var frame = animated_sprite.frame
						animated_sprite.play("hit_shadow_bolt_right_end")
						animated_sprite.frame = frame
				else:
					var frame = animated_sprite.frame
					animated_sprite.frame = frame
					animated_sprite.play("hit_move_right")
			# set the playing_hit_animation to true
			playing_hit_animation = true
			# play the hit sound
			hit_sound.play()
		# if the health is 0 or less
		if health <= 0:
			# set the state to dying
			dying = true
			# play the dying animation
			animated_sprite.play("dying")
			# set movement velocity to 0 (stops movement)
			velocity = Vector2(0.0,0.0)
			# plays the sound sound and starts the death timer
			death_timer.start()
			death_sound.play()

# when death timer ends
func _on_death_timer_timeout():
	# unlock the shade in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.shade)
	# call enemy slain
	enemy_slain()

# when spawn timer ends
func _on_spawn_timer_timeout():
	spawning = false

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the shade attacks
func attack():
	# set bool variables
	attacking = true
	can_move = false
	can_attack = false
	# play the correct attack direction
	if current_direction == look_direction.left:
		animated_sprite.play("shadow_bolt_left_start")
	elif current_direction == look_direction.right:
		animated_sprite.play("shadow_bolt_right_start")
	# reset the can attack timer
	can_attack_timer = can_attack_timer_max
	# start the spawn timer
	shadow_bolt_spawn_timer.start()
	# start the attack timer
	shadow_bolt_attack_timer.start()

# when the shadow bolt attack timer ends
func _on_shadow_bolt_attack_timer_timeout():
	# reset the can attack timer
	can_attack_timer = can_attack_timer_max
	# allow the shade to move
	can_move = true
	attacking = false

# spawns 1 shadow bolt
func spawn_shadow_bolt():
	# increase the amount of shadow bolts spawned in this burst
	spawned_in_current_burst += 1
	# play the attack sound
	attack_sound.play()
	# soawb the shadow bolt
	var shadow_bolt = SHADOW_BOLT.instantiate()
	if current_direction == look_direction.left:
		shadow_bolt.global_position = shadow_bolt_spawn_left.global_position
	elif current_direction == look_direction.right:
		shadow_bolt.global_position = shadow_bolt_spawn_right.global_position
	get_parent().add_child(shadow_bolt)
	# tell the shadow bolt that it spawned
	shadow_bolt.spawned(self, false)
	# start the time between shadow bolts burst timer
	time_between_shadow_bolts_burst.start()

# when the time between shadow bolts burst timer ends
func _on_time_between_shadow_bolts_burst_timeout():
	# if the max shadow bolts in this burst have not been reached
	if spawned_in_current_burst < max_spawn_in_burst:
		# spawn another shadow bolt
		spawn_shadow_bolt()
	# if the max shadow bolts per burst has been reached
	else:
		# reset the shadow bolts spawned in this burst
		spawned_in_current_burst = 0
		# play the correct attack ending animation
		if current_direction == look_direction.left:
			animated_sprite.play("shadow_bolt_left_end")
		elif current_direction == look_direction.right:
			animated_sprite.play("shadow_bolt_right_end")

# when the shadow bolt spawn timer ends
func _on_shadow_bolt_spawn_timer_timeout():
	# spawn a shadow bolt
	spawn_shadow_bolt()
