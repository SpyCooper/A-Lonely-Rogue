extends Enemy

enum state
{
	grounded,
	attacking,
	landing,
}

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_player = $DamagePlayer
@onready var attack_timer = $Attack_timer
@onready var death_timer = $Death_timer
@onready var spawn_timer = $Spawn_timer
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
const ENEMY_HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")
const RANDOM_ITEM_SPAWNER = preload("res://Scenes/random_item_spawner.tscn")

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var death_sound = $DeathSound
@onready var attack_sound = $attack_sound

# attack variables
var jump_direction = Vector2(0,0)
var previous_speed = Vector2(0,0)

# basic enemy variables
var current_direction : look_direction
var can_attack = false
var can_move = true
var attacking = false
var next_attack_use_object_position = false
var current_state = state.grounded

# on start
func _ready():
	# basic enemy stats
	speed = 4.0
	health = 45
	max_health = health
	# sets references to the player and catalog
	catalog = Events.catalog
	player = Events.player
	# disables the enemy
	sleep()

# defines the wake_up function needed for the mimic
## this is called by the rooms when a player enters it
func wake_up():
	player_in_room = true
	# runs spawn_in()
	spawn_in()

# called every frame
func _physics_process(_delta):
	# if the player is in the room, not dying, and not spawning
	if player_in_room && !dying && !spawning:
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# if the mimic can attack
			if current_state == state.grounded && can_attack:
				# do an attack
				attack()
			# if the mimic is attacking
			elif current_state == state.attacking:
				# if the distance to the attack position is greater than 3
				if animated_sprite.global_position.distance_to(player_position) > 3:
					## has to use get_speed() to move based on dusted effect
					# check for a collision
					var collision = move_and_collide(jump_direction.normalized() * get_speed())
					# set the previous speed
					previous_speed = jump_direction.normalized() * get_speed()
					# if there was a collision
					if collision != null:
						if collision.get_collider() is wall_collider:
							next_attack_use_object_position = true
						# land
						land()
				else:
					# land
					land()
			# if the current state is landing
			elif current_state == state.landing:
				# reduce the speed until the mimic stops
				var temp = Vector2(abs(previous_speed.x), abs(previous_speed.y))
				if temp > Vector2(0.5 , 0.5):
					previous_speed = previous_speed * 0.95
					move_and_collide(previous_speed)
				else:
					# when the mimic lands, the state is grounded and start the attack timer
					current_state = state.grounded
					attack_timer.start()

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
		Events.hud.adjust_health_bar(health)
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
	Events.hud.hide_health_bar()
	# unlock the enemy in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.mimic)
	# spawn a random item when the mimic dies
	var random_item = RANDOM_ITEM_SPAWNER.instantiate()
	random_item.position = position
	var item = random_item
	get_tree().current_scene.add_child(random_item)
	item.spawn_item()
	# call enemy_slain()
	enemy_slain()

# when spawning in
func spawn_in():
	# set the mimic state to spawning
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
	# show the mimic's health bar in the HUD
	Events.hud.set_health_bar(max_health, "Mimic")
	# starts the attack timer
	attack_timer.start()

# does an attack
func attack():
	if !dying:
		# gets the player's position
		player_position = player.get_player_position()
		if next_attack_use_object_position:
			player_position = Events.current_room.global_position
			next_attack_use_object_position = false
		jump_direction = (player_position - animated_sprite.global_position).normalized()
		current_direction = get_left_right_look_direction(jump_direction)
		# plays the correct attack animation
		if current_direction == look_direction.right:
			animated_sprite.play("attack_right")
		elif current_direction == look_direction.left:
			animated_sprite.play("attack_left")
		# disables attacks and sets the state to attacking
		can_attack = false
		current_state = state.attacking
		# plays the attack sound
		attack_sound.play()

# lands the mimic after an attack
func land():
	if !dying:
		# plays the correct landing animation
		if current_direction == look_direction.right:
			animated_sprite.play("land_right")
		elif current_direction == look_direction.left:
			animated_sprite.play("land_left")
		# sets the current state to landing
		current_state = state.landing

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the mimic to attack
	can_attack = true

# when the attacks end
func attack_end():
	# allow the mimic to move
	can_move = true
	# start the attack timer
	attack_timer.start()

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null
