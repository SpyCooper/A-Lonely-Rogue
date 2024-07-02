extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_timer = $death_timer
@onready var death_sound = $DeathSound
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_timer = $Spawn_timer
@onready var exist_sound = $exist_sound
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
const ENEMY_HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")
@onready var damage_player = $DamagePlayer

# throw tornado variables
var can_throw = false
var thrown = false
var throw_timer_max = 2.25
var throw_timer = throw_timer_max
var thrown_counter = 0
const TORNADO = preload("res://Scenes/enemies/tornado/tornado.tscn")
@onready var time_between_attacks_timer = $time_between_attacks_timer

# general enemy variables
var target_position
var current_direction : look_direction

# variables
var can_move = true

# sets the enemy's stats and references
func _ready():
	speed = .7
	health = 10
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog

# on start
func wake_up():
	# player is now in the room
	player_in_room = true
	# the spawn animation is played
	animated_sprite.play("spawning")
	# the spawn_timer is started
	spawn_timer.start()
	# the spawn sound in played
	spawn_sound.play()

# every frame
func _process(delta):
	# determine if the elemental can throw or not
	if !can_throw && !dying && !spawning:
		throw_timer -= delta
	if throw_timer <= 0:
		can_throw = true

# called every frame
func _physics_process(_delta):
	# if the player is in the room, the air elemental isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# flips the direction of the air elemental based on the current_direction
			## NOTE: all these checks are identical but change the directions they look at
			## Move left
			if current_direction == look_direction.left :
				# plays the basic move animation and sets the playing_hit_animation to false
				animated_sprite.play("move_left")
			## Move right
			elif current_direction == look_direction.right:
				animated_sprite.play("move_right")
			# if the air elemental can throw tornados
			if can_throw && position.distance_to(player_position) < 80:
				# reset the throw
				can_throw = false
				# reset the throw timer
				throw_timer = throw_timer_max
				# throw the first tornado
				throw_tornado()
			# if the enemy is not within 60 pixels of the player
			elif position.distance_to(player_position) > 60:
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
		# add the damage to the player's stats
		PlayerData.damage_dealt += damage
		# if health is greater than 0
		if health > 0:
			# plays the hit animation
			animated_sprite.material.shader = null
			animated_sprite.material.shader = ENEMY_HIT_SHADER
			hit_flash_animation_player.play("hit_flash")
			hit_flash_animation_timer.start()
			# plays the hit sound
			hit_sound.play()
		# if the health is 0 or less
		if health <= 0:
			# stop wind existing sound
			exist_sound.stop()
			# set the state to dying
			dying = true
			# play the dying animation
			animated_sprite.play("dying")
			# set movement velocity to 0 (stops movement)
			velocity = Vector2(0.0,0.0)
			# plays the sound sound and starts the death timer
			death_timer.start()
			death_sound.play()
			# remove the damage player hitbox
			damage_player.queue_free()
			remove_hitbox()

# when death timer ends
func _on_death_timer_timeout():
	# unlock the air elemental in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.air_elemental)
	# call enemy slain
	enemy_slain()

# when spawn timer ends
func _on_spawn_timer_timeout():
	spawning = false
	# play the sound of the air elemental exising
	exist_sound.play()

# throw a tornado at the player
func throw_tornado():
	# checks to make sure the character isn't dying
	if !dying:
		# get the player's position
		player_position = player.position
		target_position = (player_position - global_position).normalized()
		# create and spawn the tornado to move toward the player's direction
		var tornado = TORNADO.instantiate()
		get_parent().add_child(tornado)
		tornado.global_position = global_position
		tornado.spawned(target_position, current_direction)
		# increase the amount of tornados in this throw
		thrown_counter += 1
		# start the time between throws timer
		time_between_attacks_timer.start()

# when the time between throws timer ends
func _on_time_between_attacks_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		# if 3 throws have not been reached
		if thrown_counter < 3:
			# throw another tornado
			throw_tornado()
		# if 3 tornados have been thrown, reset the counter
		else:
			thrown_counter = 0

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null
