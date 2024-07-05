extends skeleton_warrior

# object references
@onready var hud = %HUD
const LARGE_SLASH_PROJECTILE = preload("res://Scenes/enemies/slash_projectile/large_slash_projectile.tscn")
# attack variables

var slash_count = 0
var slash_count_max = 2

# sets the enemy's stats and references
func _ready():
	speed = .5
	health = 55
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog
	can_attack_timer_max = 2
	can_attack_timer = can_attack_timer_max

# on every frame
func _process(delta):
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
	# if the player is in the room, the skeleton warrior isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.get_player_position()
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# if the enemy can attack and is less than 50 pixels away from the player
			if can_attack && position.distance_to(player_position) < 75:
				# attack
				attack()
			# if the enemy is further than 50 pixels
			elif position.distance_to(player_position) >= 75:
				# look in the direction of the player
				# flips the direction of the skeleton warrior based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					# plays the basic move animation and sets the playing_hit_animation to false
					animated_sprite.play("move_left")
					is_idle = false
				## Move right
				elif current_direction == look_direction.right:
					animated_sprite.play("move_right")
					is_idle = false
				## has to use get_speed() to move based on dusted effect
				move_and_collide(target_position.normalized() * get_speed())
			# if the enemy is not attacking
			elif !attacking:
				# play the idle left or right animation
				if current_direction == look_direction.left:
					animated_sprite.play("idle_left")
					is_idle = true
				elif current_direction == look_direction.right:
					animated_sprite.play("idle_right")
					is_idle = true

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
		# adjust the boss health bar in the HUD
		hud.adjust_health_bar(health)
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
	# hide the health bar
	hud.hide_health_bar()
	# unlock the skeleton warrior in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.emerald_skeleton)
	# call enemy slain
	enemy_slain()

# when spawn timer ends
func _on_spawn_timer_timeout():
	spawning = false
	# show the lich's health bar in the HUD
	hud.set_health_bar(max_health, "Emerald Skeleton")

# when the slash projection spawn animation timer
func _on_slash_projection_spawn_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		if slash_count < slash_count_max:
			# get the player position
			player_position = player.get_player_position()
			target_position = (player_position - global_position).normalized()
			# spawn the clash projectile
			var slash = LARGE_SLASH_PROJECTILE.instantiate()
			get_parent().add_child(slash)
			# set the slash position
			slash.global_position = animated_sprite.global_position
			# tell the slash that it spawned
			slash.spawned(target_position)
			slash_count += 1
			slash_projection_spawn_timer.start()
			if current_direction == look_direction.right:
				if slash_count == 2:
					slash.animated_sprite.flip_v = true
			elif current_direction == look_direction.left:
				if slash_count == 1:
					slash.animated_sprite.flip_v = true
		else:
			slash_count = 0
