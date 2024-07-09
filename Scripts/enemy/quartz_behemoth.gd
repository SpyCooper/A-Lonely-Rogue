extends Enemy

enum state
{
	spawning_spikes,
	dashing,
	idle,
}

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_player = $DamagePlayer
@onready var attack_timer = $Attack_timer
@onready var death_timer = $Death_timer
@onready var hud = %HUD
@onready var spawn_timer = $Spawn_timer
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
const ENEMY_HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var death_sound = $DeathSound
@onready var spawn_sound_timer = $Spawn_sound_timer

# dash references
@onready var after_image_spawn_timer = $After_image_spawn_timer
@onready var dash_timer = $dash_timer
const QUARTZ_BEHEMOTH_AFTER_IMAGE = preload("res://Scenes/enemies/after_images/quartz_behemoth_after_image.tscn")
var dash_direction = Vector2(0, 0)

# spike attack variables
var spikes_active = false
@onready var spike_attack_duration = $spike_attack_duration
@onready var spike_attack_animation_timer = $spike_attack_animation_timer
@onready var spikes_spawn_start_offset_timer = $spikes_spawn_start_offset_timer
@onready var spawn_spikes_timer = $spawn_spikes_timer
const QUARTZ_SPIKE = preload("res://Scenes/enemies/quartz_spike/quartz_spike.tscn")

# defines a random number generator
var rng = RandomNumberGenerator.new()

# basic enemy variables
var target_position
var current_direction : look_direction
var can_attack = false
var can_move = true
var current_state = state.idle

# on start
func _ready():
	# basic enemy stats
	speed = 4.0
	health = 50
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
			player_position = player.get_player_position()
			target_position = (player_position - global_position).normalized()
			# if the golem can attack
			if can_attack:
				# do a random attack
				random_attack()
			elif current_state == state.dashing:
				current_direction = get_left_right_look_direction(dash_direction)
				
				if current_direction == look_direction.right:
					animated_sprite.play("dash_right")
				elif current_direction == look_direction.left:
					animated_sprite.play("dash_left")
				
				if animated_sprite.global_position.distance_to(player_position) > 40:
					var collision = move_and_collide(dash_direction * get_speed())
					#print(collision)
					if collision != null:
						random_dash_direction(true)
				else:
					dash_direction = (Vector2(0 - target_position.x, 0 -  target_position.y)).normalized()
					move_and_collide(dash_direction * get_speed())
			# if the enemy can move
			elif current_state == state.idle:
				current_direction = get_left_right_look_direction(target_position)
				# flips the direction of the golem based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					# plays the basic move animation and sets the playing_hit_animation to false
					animated_sprite.play("look_left")
				## Move right
				elif current_direction == look_direction.right:
					animated_sprite.play("look_right")
				### NOTE: the golem cannot move currently but this is here just in case this is changes
				## moves the golem to a distance of 15 to the player
				#if position.distance_to(player_position) > 15:
					### has to use get_speed() to move based on dusted effect
					#move_and_collide(target_position.normalized() * get_speed())

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
		# deals the damage to the enemy
		health -= damage
		# add the damage to the player's stats
		PlayerData.damage_dealt += damage
		# adjust the boss health bar in the HUD
		hud.adjust_health_bar(health)
		# plays the hit sound if the HP after damage is > 0
		if health > 0:
			# plays the hit animation
			animated_sprite.material.shader = null
			animated_sprite.material.shader = ENEMY_HIT_SHADER
			hit_flash_animation_player.play("hit_flash")
			hit_flash_animation_timer.start()
			# plays the hit sound
			hit_sound.play()
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
			# remove the damage player hitbox
			damage_player.queue_free()
			remove_hitbox()

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the death timer runs out
func _on_death_timer_timeout():
	# hide the health bar
	hud.hide_health_bar()
	# unlock the enemy in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.quartz_behemoth)
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
	hud.set_health_bar(max_health, "Quartz Behemoth")

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the golem to attack
	can_attack = true

# when the golem is doing a random attack
func random_attack():
	# checks to make sure the character isn't dying
	if !dying:
		# set bools for attacking
		can_attack = false
		# does dashes if spikes are not active
		if spikes_active:
			dash()
		else:
			spike_attack()

# when the attacks end
func attack_end():
	# allow the golem to move
	can_move = true
	
	if spikes_active:
		# start the attack timer
		attack_timer.start(rng.randf_range(0.7, 3.0))
	else:
		attack_timer.start(3)
	current_state = state.idle

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null

# when the player dashes
func dash():
	# checks to make sure the character isn't dying
	if !dying:
		# gets a new dash direction
		random_dash_direction(false)
		# plays the right dash_direction
		if get_left_right_look_direction(dash_direction) == look_direction.right:
			animated_sprite.play("dash_right")
		elif get_left_right_look_direction(dash_direction) == look_direction.left:
			animated_sprite.play("dash_left")
		# start the dash timer
		dash_timer.start()
		# set that the player is dashing
		current_state = state.dashing
		# start the after image spawn timer
		after_image_spawn_timer.start()

# set a new random direction
func random_dash_direction(hit_object : bool):
	# sets a base direction as the current move direction
	var vector_normalized = dash_direction
	# if the morphed shade collided with an object
	if hit_object:
		# find a random vector that is not in the direction of the object
		## x direction
		var vec_x = rng.randf_range(0.1, 1)
		var pos_or_neg = rng.randi_range(-1, 1)
		if dash_direction.x < 0:
			pos_or_neg = rng.randi_range(0.1, 1)
		if dash_direction.x > 0:
			pos_or_neg = rng.randi_range(-1, 0)
		vec_x = pos_or_neg * vec_x
		## y direction
		var vec_y = rng.randf_range(0.1, 1)
		pos_or_neg = rng.randi_range(-1, 1)
		if dash_direction.y < 0:
			pos_or_neg = rng.randi_range(0.1, 1)
		if dash_direction.y > 0:
			pos_or_neg = rng.randi_range(-1, 0)
		vec_y = pos_or_neg * vec_y
		# normalize the movement vector
		vector_normalized = Vector2(vec_x, vec_y).normalized()
		# set the current move direction
		dash_direction = vector_normalized
	else:
		# find a random vector
		## x direction
		var vec_x = rng.randf_range(0, 1)
		var pos_or_neg = rng.randi_range(-1, 1)
		vec_x = pos_or_neg * vec_x
		## y direction
		var vec_y = rng.randf_range(0, 1)
		pos_or_neg = rng.randi_range(-1, 1)
		vec_y = pos_or_neg * vec_y
		# normalize the movement vector
		vector_normalized = Vector2(vec_x, vec_y).normalized()
		# set the current move direction
		dash_direction = vector_normalized
	# checks to see if the direction is 0,0
	if dash_direction == Vector2(0,0):
		# find a random vector
		## x direction
		var vec_x = rng.randf_range(0, 1)
		var pos_or_neg = rng.randi_range(-1, 1)
		vec_x = pos_or_neg * vec_x
		## y direction
		var vec_y = rng.randf_range(0, 1)
		pos_or_neg = rng.randi_range(-1, 1)
		vec_y = pos_or_neg * vec_y
		# normalize the movement vector
		vector_normalized = Vector2(vec_x, vec_y).normalized()
		# set the current move direction
		dash_direction = vector_normalized

# when the after image spawn timer ends
func _on_after_image_spawn_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		if current_state == state.dashing:
			# spawn an after image
			var after_image = QUARTZ_BEHEMOTH_AFTER_IMAGE.instantiate()
			get_parent().add_child(after_image)
			after_image.global_position = get_animated_sprite().global_position
			if animated_sprite.animation == "dash_right":
				after_image.spawned("right")
			elif animated_sprite.animation == "dash_left":
				after_image.spawned("left")
			# start the after image spawn timer
			after_image_spawn_timer.start()

# when the dash timer ends
func _on_dash_timer_timeout():
	attack_end()

func spike_attack():
	# checks to make sure the character isn't dying
	if !dying:
		spikes_active = true
		
		current_state = state.spawning_spikes
		
		if current_direction == look_direction.right:
			animated_sprite.play("attack_right")
		elif current_direction == look_direction.left:
			animated_sprite.play("attack_left")
		
		spike_attack_animation_timer.start()
		spikes_spawn_start_offset_timer.start()

func _on_spike_attack_duration_timeout():
	spikes_active = false
	can_attack = false
	
	attack_end()

func _on_spike_attack_animation_timer_timeout():
	attack_end()

func _on_spikes_spawn_start_offset_timer_timeout():
	spike_attack_duration.start()
	spawn_spike()
	spawn_spikes_timer.start()

func _on_spawn_spikes_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		spawn_spike()
		if spikes_active:
			spawn_spikes_timer.start()

func spawn_spike():
	# checks to make sure the character isn't dying
	if !dying:
		# spawns the vine spin
		var spike = QUARTZ_SPIKE.instantiate()
		get_parent().add_child(spike)
		spike.set_spawn_position(player.get_player_position())

