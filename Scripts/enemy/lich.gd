extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_player = $DamagePlayer
@onready var attack_timer = $Attack_timer
@onready var death_timer = $Death_timer
@onready var spawn_timer = $Spawn_timer
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
const ENEMY_HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var death_sound = $DeathSound
@onready var magic_casting_sound = $magic_casting_sound
@onready var lightning_strike_sound = $lightning_strike_sound

# spawn skeletons attack variables
@onready var spawn_skeletons_anim_timer = $spawn_skeletons_anim_timer
@onready var skeleton_spawn_left_location = $skeleton_spawn_left_location
@onready var lightning_left = $skeleton_spawn_left_location/lightning_left
@onready var skeleton_spawn_right_location = $skeleton_spawn_right_location
@onready var lightning_right = $skeleton_spawn_right_location/lightning_right
@onready var lightning_timer = $lightning_timer
@onready var delay_lighning_timer = $delay_lighning_timer
const SKELETON_ARCHER = preload("res://Scenes/enemies/skeleton_archer.tscn")
const SKELETON_MAGE = preload("res://Scenes/enemies/skeleton_mage.tscn")
const SKELETON_WARRIOR = preload("res://Scenes/enemies/skeleton_warrior.tscn")

# shadow ball attack references
@onready var shadow_ball_anim_timer = $shadow_ball_anim_timer
@onready var shadow_ball_spawn_right = $Shadow_ball_spawn_right
@onready var shadow_ball_spawn_left = $Shadow_ball_spawn_left
@onready var shadow_ball_spawn_timer = $shadow_ball_spawn_timer
const SHADOW_BALL = preload("res://Scenes/enemies/shadow_bolt/shadow_ball.tscn")

# poison area attack references
const POISON_AREA = preload("res://Scenes/enemies/poison_area/poison_area.tscn")
@onready var summon_poison_anim_timer = $"summon poison_anim_timer"
@onready var summon_poison_spawn_timer = $"summon poison_spawn_timer"
@onready var delay_player_pos_timer = $delay_player_pos_timer
var temp_player_pos

# heal attack variables
@onready var heal_animation_timer = $heal_animation_timer
const SKELETON_UNARMED = preload("res://Scenes/enemies/skeleton_unarmed.tscn")
@onready var summon_one_lighning_timer = $summon_one_lighning_timer
@onready var lighning_duration_heal_timer = $lighning_duration_heal_timer
@onready var time_before_heal_timer = $time_before_heal_timer
var unarmed_skeleton
var heal_amount = 15
const LIGHTNING = preload("res://Scenes/enemies/lightning/lightning.tscn")
var temp_lightning
@onready var temp_lightning_timer = $temp_lightning_timer

# defines a random number generator
var rng = RandomNumberGenerator.new()

# basic enemy variables
var target_position
var current_direction : look_direction
var can_attack = false
var can_move = true

# on start
func _ready():
	# basic enemy stats
	speed = 0.4
	max_health = 90
	health = max_health
	# sets references to the player and catalog
	catalog = Events.catalog
	player = Events.player
	# disables the enemy
	sleep()
	# hides the lighning animated sprites
	hide_lightning()

# defines the wake_up function needed for the lich
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
			target_position = (player_position - animated_sprite.global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# if the lich can attack
			if can_attack:
				# do a random attack
				random_attack()
			# if the enemy can move (cannot move when attacking)
			elif can_move:
				# flips the direction of the lich based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					# plays the basic move animation
					animated_sprite.play("move_left")
				## Move right
				elif current_direction == look_direction.right:
					animated_sprite.play("move_right")
				# moves the lich to a distance of 15 to the player
				if animated_sprite.global_position.distance_to(player_position) > 8 && !player_in_damage_area:
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
			# spawn_sound is the portal sound
			spawn_sound.play()
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
	catalog.unlock_enemy(EnemyTypes.enemy.lich)
	# call enemy_slain()
	enemy_slain()

# when spawning in
func spawn_in():
	# set the lich state to spawning
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
	# show the lich's health bar in the HUD
	Events.hud.set_health_bar(max_health, "Lich")

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the lich to attack
	can_attack = true

# when the lich is doing a random attack
func random_attack():
	# set bools for attacking
	can_move = false
	can_attack = false
	# does a random attack
	var random_number = rng.randi_range(0, 12)
	# 1/4 chance
	if random_number <= 2:
		shadow_ball_attack()
	# 1/4 chance
	elif random_number <= 5:
		spawn_skeletons_attack()
	# 1/4 chance
	elif random_number <= 8:
		summon_poison()
	# 1/4 chance
	else:
		heal_attack()

# when the attacks end
func attack_end():
	# allow the lich to move
	can_move = true
	# start the attack timer
	attack_timer.start()

# when the lich does a spawn skeleton attack
func spawn_skeletons_attack():
	# start the spawn skeletons animation timer
	spawn_skeletons_anim_timer.start()
	# play the correct spawn skeletons animation
	if current_direction == look_direction.left:
		animated_sprite.play("spawn_skeletons_left")
	elif current_direction == look_direction.right:
		animated_sprite.play("spawn_skeletons_right")
	# start the delay lightning timer
	delay_lighning_timer.start()

# when the spawn skeletons animation timer ends
func _on_spawn_skeletons_anim_timer_timeout():
	# end the attack
	attack_end()

# when the delay lightning timer ends
func _on_delay_lighning_timer_timeout():
	# play the lightning sound
	lightning_strike_sound.play()
	# show the left and right lighning animated sprites
	lightning_left.show()
	lightning_right.show()
	# start the lightning timer
	lightning_timer.start()

# when the lightning timer ends
func _on_lightning_timer_timeout():
	# hide the lightning animated sprites
	hide_lightning()
	# spawn skeletons
	spawn_skeletons()

# hide the lightning animated sprites
func hide_lightning():
	lightning_left.hide()
	lightning_right.hide()

# spawns two random skeletons
func spawn_skeletons():
	# checks to make sure the character isn't dying
	if !dying:
		# runs twice
		for n in [1, 2]:
			# gets a random type of skeleton
			var random_number = rng.randi_range(1, 3)
			var random_skel = SKELETON_WARRIOR
			if random_number == 1:
				random_skel = SKELETON_ARCHER
			elif random_number == 2:
				random_skel = SKELETON_MAGE
			elif random_number == 3:
				random_skel = SKELETON_WARRIOR
			# set the correct spawn location for this iteration
			var spawn_location
			if n == 1:
				spawn_location = skeleton_spawn_left_location
			elif n == 2:
				spawn_location = skeleton_spawn_right_location
			# spawns the skeleton for this iteration
			var skel = random_skel.instantiate()
			add_child(skel)
			skel.reparent(get_tree().current_scene)
			skel.spawned_in_room()
			# set the skeleton's position
			skel.global_position = spawn_location.global_position

# when the lich does a shadow ball attack
func shadow_ball_attack():
	# checks to make sure the character isn't dying
	if !dying:
		# plays the correct animation for the shadow_ball attack
		if current_direction == look_direction.right:
			animated_sprite.play("shadow_ball_right")
		elif current_direction == look_direction.left:
			animated_sprite.play("shadow_ball_left")
		# starts the shadow ball animation timer
		shadow_ball_anim_timer.start()
		# starts the shadow ball spawn timer
		shadow_ball_spawn_timer.start()

# when the shadow ball animation timer ends
func _on_shadow_ball_anim_timer_timeout():
	# end the attack
	attack_end()

# starts the shadow ball spawn timer
func _on_shadow_ball_spawn_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		# spawn the shadow ball
		spawn_shadow_ball()

# spawns a shadow ball
func spawn_shadow_ball():
	# checks to make sure the character isn't dying
	if !dying:
		# play the magic casting sound
		magic_casting_sound.play()
		# gets the correct spawn location of the shadow ball
		var spawn_location = shadow_ball_spawn_right
		if current_direction == look_direction.left:
			spawn_location = shadow_ball_spawn_left
		# spawns the shadow ball at the correct position
		var shadow_ball = SHADOW_BALL.instantiate()
		shadow_ball.global_position = spawn_location.global_position
		get_tree().current_scene.add_child(shadow_ball)
		# tell the shadow ball that it spawned
		shadow_ball.spawned()

# when the lich summons poison
func summon_poison():
	# checks to make sure the character isn't dying
	if !dying:
		# play the magic casting sound
		magic_casting_sound.play()
		# play the correct casting direction (shadow_ball_right is used for single handed casting)
		if current_direction == look_direction.right:
			animated_sprite.play("shadow_ball_right")
		elif current_direction == look_direction.left:
			animated_sprite.play("shadow_ball_left")
		# grabs a temporary player position
		temp_player_pos = player.get_player_position()
		# starts the animation timer, the spawn timer, and the delayed player position timer
		summon_poison_anim_timer.start()
		summon_poison_spawn_timer.start()
		delay_player_pos_timer.start()

# when the summon poison animation timer ends
func _on_summon_poison_anim_timer_timeout():
	attack_end()

# when the summon poison spawn timer ends
func _on_summon_poison_spawn_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		# spawn the poison area
		var poison_area = POISON_AREA.instantiate()
		get_parent().add_child(poison_area)
		# tell the poison area that it's spawned
		poison_area.spawned(temp_player_pos)

# when delayed player position timer ends
func _on_delay_player_pos_timer_timeout():
	# grabs a temporary player position
	temp_player_pos = player.get_player_position()

# when the lich does a heal attack
func heal_attack():
	# checks to make sure the character isn't dying
	if !dying:
		# start the heal animation timer
		heal_animation_timer.start()
		# plays the correct animation
		if current_direction == look_direction.left:
			animated_sprite.play("heal_start_left")
		elif current_direction == look_direction.right:
			animated_sprite.play("heal_start_right")
		# starts the summon one lightning timer
		summon_one_lighning_timer.start()

# when the summon one lightning timer ends
func _on_summon_one_lighning_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		# play the lightning strike sound effect
		lightning_strike_sound.play()
		# check the current direction
		if current_direction == look_direction.left:
			# show the correct lightning
			lightning_left.show()
			# play the correct heal idle animation
			animated_sprite.play("heal_idle_left")
		else:
			lightning_right.show()
			animated_sprite.play("heal_idle_right")
		# starts the lightning duration heal timer
		lighning_duration_heal_timer.start()

# when the lightning duration heal timer ends
func _on_lighning_duration_heal_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		# hide the lightning
		hide_lightning()
		# spawn an unarmed skeleton
		spawn_unarmed_skeleton()

# spawns one unarmed skeleton for the heal attack
func spawn_unarmed_skeleton():
	# checks to make sure the character isn't dying
	if !dying:
		# set the correct skeleton spawn location
		var spawn_location = skeleton_spawn_right_location
		if current_direction == look_direction.left:
			spawn_location = skeleton_spawn_left_location
		# spawn the skeleton
		var skel = SKELETON_UNARMED.instantiate()
		add_child(skel)
		skel.reparent(get_tree().current_scene)
		skel.spawned_in_room()
		# set the skeleton's position
		skel.global_position = spawn_location.global_position
		# saves the object reference
		unarmed_skeleton = skel
		# starts the timer before heal timer
		time_before_heal_timer.start()

# when the timer before heal timer ends
func _on_time_before_heal_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		# if the unarmed skeleton still exists and isn't dying
		if unarmed_skeleton != null:
			if !unarmed_skeleton.is_dying():
				# spawn a lightning strike at that location
				temp_lightning = LIGHTNING.instantiate()
				add_child(temp_lightning)
				# adjust the lightning position
				temp_lightning.global_position = unarmed_skeleton.global_position + Vector2(0, -125)
				# start the temporary lightning timer
				temp_lightning_timer.start()
				# play the lightning strike sound effect
				lightning_strike_sound.play()
				# despawn the unarmed skeleton
				unarmed_skeleton.despawn()
				# heal the lich
				heal()
				# plays the correct heal ending success animation
				if current_direction == look_direction.right:
					animated_sprite.play("heal_end_success_right")
				else:
					animated_sprite.play("heal_end_success_left")
		# if the skeleton does not exist
		else:
			# play the correct heal ending fail animation
			if current_direction == look_direction.right:
				animated_sprite.play("heal_end_fail_right")
			else:
				animated_sprite.play("heal_end_fail_left")
			

# heals the lich
func heal():
	# checks to make sure the character isn't dying
	if !dying:
		# heals the lich for the correct amount
		if health + heal_amount > max_health:
			health = max_health
		else:
			health += heal_amount
		# adjust the boss health bar in the HUD
		Events.hud.adjust_health_bar(health)

# when the heal animation timer ends
func _on_heal_animation_timer_timeout():
	attack_end()

# when the temp lightning timer ends
func _on_temp_lightning_timer_timeout():
	# remove the temporary lightning
	temp_lightning.queue_free()

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null
