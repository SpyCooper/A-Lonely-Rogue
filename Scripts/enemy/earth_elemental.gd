extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_timer = $death_timer
@onready var death_sound = $DeathSound
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_timer = $Spawn_timer
@onready var damage_player = $DamagePlayer

# throw rocks variables
var can_throw = false
var thrown = false
var throw_timer_max = 5.0
var throw_timer = throw_timer_max
const ROLLING_ROCK = preload("res://Scenes/enemies/rolling_rock/rolling_rock.tscn")
@onready var throw_animation_timer = $"throw animation timer"
@onready var rock_spawner_up = $rock_spawner_up
@onready var rock_spawner_down = $rock_spawner_down
@onready var rock_spawner_right = $rock_spawner_right
@onready var rock_spawner_left = $rock_spawner_left
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
const ENEMY_HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")

# general enemy variables
var target_position
var current_direction : look_direction

# variables
var can_move = true

# sets the enemy's stats and references
func _ready():
	speed = .5
	health = 12
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog

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
	# if the player is in the room, the earth elemental isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.get_player_position()
			target_position = (player_position - animated_sprite.global_position).normalized()
			current_direction = get_look_direction(target_position)
			# if a rock can be thrown in mid range
			if can_throw && position.distance_to(player_position) < 120 && position.distance_to(player_position) > 70:
				# reset the throw
				can_throw = false
				throw_timer = throw_timer_max
				# stop the elemental
				can_move = false
				# start the animation timer to match the throw
				throw_animation_timer.start()
				# look in the direction of the player
				if current_direction == look_direction.up:
					animated_sprite.play("throw_up")
				elif current_direction == look_direction.down:
					animated_sprite.play("throw_down")
				elif current_direction == look_direction.right:
					animated_sprite.play("throw_right")
				elif current_direction == look_direction.left:
					animated_sprite.play("throw_left")
			else:
				# flips the direction of the earth elemental based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					# plays the basic move animation
					animated_sprite.play("move_left")
				## Move right
				elif current_direction == look_direction.right:
					animated_sprite.play("move_right")
				## Move up
				elif current_direction == look_direction.up:
						animated_sprite.play("move_up")
				## Move down
				elif current_direction == look_direction.down:
						animated_sprite.play("move_down")
				# moves the earth elemental to a distance of 8 to the player
				if animated_sprite.global_position.distance_to(player_position) > 8:
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
	# unlock the earth elemental in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.earth_elemental)
	# call enemy slain
	enemy_slain()

# when spawn timer ends
func _on_spawn_timer_timeout():
	spawning = false

# throw a rock at the player's current position
func throw_rock():
	# checks to make sure the character isn't dying
	if !dying:
		# gets the player's position and looks toward it
		player_position = player.get_player_position()
		target_position = (player_position - animated_sprite.global_position).normalized()
		# create and spawn the rock to move toward the player's direction
		var rolling_rock = ROLLING_ROCK.instantiate()
		get_parent().add_child(rolling_rock)
		if current_direction == look_direction.up:
			rolling_rock.global_position = rock_spawner_up.global_position
		elif current_direction == look_direction.down:
			rolling_rock.global_position = rock_spawner_down.global_position
		elif current_direction == look_direction.left:
			rolling_rock.global_position = rock_spawner_left.global_position
		elif current_direction == look_direction.right:
			rolling_rock.global_position = rock_spawner_right.global_position
		rolling_rock.spawned(target_position, current_direction)
		# start the animation timer
		throw_animation_timer.start()

# when the animation timer ends
func _on_throw_animation_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		# if the rock hasn't been thrown
		if !thrown:
			# spawn the rock
			throw_rock()
			# mark the rock as thrown
			thrown = true
		# if the rock has been thrown
		else:
			# reset thrown
			thrown = false
			# allow elemental to move
			can_move = true

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null
