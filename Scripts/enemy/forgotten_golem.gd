extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_player = $DamagePlayer
@onready var attack_timer = $Attack_timer
@onready var death_timer = $Death_timer
@onready var hud = %HUD
@onready var spawn_timer = $Spawn_timer

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var death_sound = $DeathSound
@onready var spawn_sound_timer = $Spawn_sound_timer

# laser attack variables
@onready var laser_spawn_timer = $Laser_spawn_timer
const LASER = preload("res://Scenes/enemies/laser/laser.tscn")
@onready var laser_spawn_right_location = $"Laser Spawn right location"
@onready var laser_spawn_left_location = $"Laser Spawn left location"
@onready var laser_attack_end_timer = $"laser attack end timer"
@onready var laser_attack_sound = $"Laser attack sound"

# summon vines attack variables
@onready var summon_vines_timer = $summon_vines_timer
@onready var summon_vines_spawn_timer = $summon_vines_spawn_timer
var summon_vines_temp_pos
const VINE_AREA = preload("res://Scenes/enemies/vine_area/vine_area.tscn")
var vines_active = false
@onready var delay_player_position_timer = $delay_player_position_timer
@onready var attack_sound = $attack_sound

# vine spin variables
const VINE_SPIN = preload("res://Scenes/enemies/vine_spin/vine_spin.tscn")
@onready var vine_spin_animation_timer = $vine_spin_animation_timer
@onready var vine_spin_summon_timer = $vine_spin_summon_timer

# defines a random number generator
var rng = RandomNumberGenerator.new()

# basic enemy variables
var target_position
var current_direction : look_direction
var playing_hit_animation = false
var can_attack = false
var can_move = true

# on start
func _ready():
	# basic enemy stats
	speed = 0.0
	health = 80
	max_health = health
	# sets references to the player and catalog
	catalog = Events.catalog
	player = Events.player
	# disables the enemy
	sleep()

# defines the wake_up function needed for the golem
## this is called by the rooms when a player enters it
func wake_up():
	player_in_room = true
	# runs spawn_in()
	spawn_in()
	# starts the attack timer
	attack_timer.start()

# called every frame
func _physics_process(_delta):
	# if the player is in the room, not dying, and not spawning
	if player_in_room && !dying && !spawning:
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# if the golem can attack
			if can_attack:
				# do a random attack
				random_attack()
			# if the enemy can move
			elif can_move:
				# flips the direction of the golem based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					# if any of the hit animations are playing
					if animated_sprite.animation == "hit_right":
						# switch to the same frame of the hit animation in the new direction
						# this keeps hit animations running for the same duration
						var frame = animated_sprite.frame
						animated_sprite.play("hit_left")
						animated_sprite.frame = frame
					# if a hit animation is not actively playing a hit animation
					elif playing_hit_animation != true || animated_sprite.is_playing() == false:
						# plays the basic move animation and sets the playing_hit_animation to false
						animated_sprite.play("look_left")
						playing_hit_animation = false
				## Move right
				elif current_direction == look_direction.right:
					if animated_sprite.animation == "hit_left":
						var frame = animated_sprite.frame
						animated_sprite.play("hit_right")
						animated_sprite.frame = frame
					elif playing_hit_animation != true || animated_sprite.is_playing() == false:
						animated_sprite.play("look_right")
						playing_hit_animation = false
				## NOTE: the golem cannot move currently but this is here just in case this is changes
				# moves the golem to a distance of 15 to the player
				if position.distance_to(player_position) > 15:
					## has to use get_speed() to move based on dusted effect
					move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	# checks if the enemy is spawning or dying
	if !spawning && !dying:
		# deals the damage to the enemy
		health -= damage
		# plays the hit sound if the HP after damage is > 0
		if health > 0:
			# plays the hit sound
			hit_sound.play()
			# if the golem can move (i.e. not attacking)
			if can_move:
				# plays the hit animation based on the current direction
				if current_direction == look_direction.left:
					var frame = animated_sprite.frame
					animated_sprite.play("hit_left")
					animated_sprite.frame = frame
				elif current_direction == look_direction.right:
					var frame = animated_sprite.frame
					animated_sprite.play("hit_right")
					animated_sprite.frame = frame
				# sets the playing_hit_animation
				playing_hit_animation = true
		# checks if the enemy should be dead
		elif health <= 0:
			# sets the enemy's state to dying
			dying = true
			# starts the death animation timer
			death_timer.start()
			# plays the death animation
			animated_sprite.play("dying")
			# plays the death sound
			death_sound.play()
		# adjust the boss health bar in the HUD
		hud.adjust_health_bar(health)

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the death timer runs out
func _on_death_timer_timeout():
	# hide the health bar
	hud.hide_health_bar()
	# unlock the enemy in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.forgotten_golem)
	# call enemy_slain()
	enemy_slain()

# when spawning in
func spawn_in():
	# set the golem state to spawning
	spawning = true
	# play spawning animation
	animated_sprite.play("spawning")
	# start the spawn timer
	spawn_timer.start()
	# play the spawn sound
	spawn_sound.play()

# when the spawn timer ends
func _on_spawn_timer_timeout():
	# the state is no longer spawning
	spawning = false
	# show the golem's health bar in the HUD
	hud.set_health_bar(max_health, "A Forgotten Golem")

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the golem to attack
	can_attack = true

# when the golem is doing a random attack
func random_attack():
	# set bools for attacking
	can_move = false
	can_attack = false
	# does a random attack
	var random_number = rng.randi_range(1, 10)
	# 2/10 chance
	if random_number <= 2:
		# does a laser attack
		laser_attack()
	# 3/10 chance
	elif random_number <= 5:
		# if there are already vines active, it will do a different attack
		if vines_active:
			# each attack has a 1/2 chance to occur
			var new_random = rng.randi_range(1, 2)
			if new_random == 1:
				laser_attack()
			else:
				vine_spin_attack()
		else:
			summon_vines()
	# 4/10 chance to do a vine spin
	elif random_number <= 9:
		# does a vine spin attack
		vine_spin_attack()
	# 1/10 chance to not attack
	else:
		# does a laser attack
		attack_end()

# when the golem is doing a laser attack
func laser_attack():
	# look in the correct direction
	if current_direction == look_direction.right:
		animated_sprite.play("laser_right")
	elif current_direction == look_direction.left:
		animated_sprite.play("laser_left")
	# start the laser spawn timer
	laser_spawn_timer.start()
	# start the laser attack end timer
	laser_attack_end_timer.start()

# when the laser spawn timer ends
func _on_laser_spawn_timer_timeout():
	# set the correct laser spawn location
	var laser_spawn_location = laser_spawn_right_location
	if current_direction == look_direction.left:
		laser_spawn_location = laser_spawn_left_location
	# get the player position
	player_position = player.position
	target_position = (player_position - laser_spawn_location.global_position).normalized()
	# spawn the laser
	var laser = LASER.instantiate()
	get_parent().add_child(laser)
	# set the laser's position
	laser.global_position = laser_spawn_location.global_position
	# tell the laser that it's spawned
	laser.spawned(target_position)
	# play the laser attack sound
	laser_attack_sound.play()

# when the laser attack end timer ends
func _on_laser_attack_end_timer_timeout():
	# end the attack
	attack_end()

# summons vines
func summon_vines():
	# play the correct vine summon animation
	if current_direction == look_direction.right:
		animated_sprite.play("vines_summon_right")
	elif current_direction == look_direction.left:
		animated_sprite.play("vines_summon_left")
	# play the attack sound
	attack_sound.play()
	# sets a temp position to spawn the vines
	summon_vines_temp_pos = player.global_position
	# start the summon vines timer (for the animation)
	summon_vines_timer.start()
	# start the summon vines spawn timer (used to actually spawn the vines)
	summon_vines_spawn_timer.start()
	# start the delayed player position timer (used to get a closer player position to when the vines spawn)
	delay_player_position_timer.start()

# when the summon vines timer ends
func _on_summon_vines_timer_timeout():
	# end the attack
	attack_end()

# when the summon vines spawn timer ends
func _on_summon_vines_spawn_timer_timeout():
	# spawn the vine area
	var vine_area = VINE_AREA.instantiate()
	get_parent().add_child(vine_area)
	# tell the vine area that it's spawned
	vine_area.spawned(self, summon_vines_temp_pos)
	# set the active vines to true
	vines_active = true

# when the vine area leaves, it calls this
func vines_expired():
	# sets the vines active to false
	vines_active = false

# when the delay player position timer ends
func _on_delay_player_position_timer_timeout():
	# sets a temp position to spawn the vines
	summon_vines_temp_pos = player.global_position

# when the golem does a vine spin attack
func vine_spin_attack():
	# sets the correct vine spin animation
	if current_direction == look_direction.right:
		animated_sprite.play("vine_spin_right")
	elif current_direction == look_direction.left:
		animated_sprite.play("vine_spin_left")
	# play the attack sound
	attack_sound.play()
	# start the vine spin timers
	vine_spin_animation_timer.start()
	vine_spin_summon_timer.start()

# when the vines spin animation timer ends
func _on_vine_spin_animation_timer_timeout():
	# end the attack
	attack_end()

# when the vines spin summon timer ends
func _on_vine_spin_summon_timer_timeout():
	# spawns the vine spin
	var vine_spin_scene = VINE_SPIN.instantiate()
	get_parent().add_child(vine_spin_scene)
	vine_spin_scene.global_position = player.global_position

# when the attacks end
func attack_end():
	# allow the golem to move
	can_move = true
	# start the attack timer
	attack_timer.start()
