extends Enemy

# sets the enemies state
enum state
{
	attack,
	healing,
	jump,
	jump_attack,
	rolling,
	running,
	idle,
}

enum attack
{
	quad,
	jump,
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
@onready var center_marker = $center_marker
@onready var death_sound_timer = $Death_sound_timer
@onready var short_attack_timer = $short_attack_timer

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_sound_timer = $Spawn_sound_timer
@onready var death_sound = $death_sound

# heal variables
var can_heal = true
@onready var heal_timer = $heal_timer
@onready var heal_sound = $heal_sound
@onready var idle_until_heal = $idle_until_heal
@onready var heal_sound_timer = $heal_sound_timer
var healing = false

# quad attack variables
@onready var quad_attack_timer = $quad_attack_timer
@onready var attack_1_timer = $attack_1_timer
@onready var attack_2_timer = $attack_2_timer
@onready var attack_3_timer = $attack_3_timer
@onready var attack_4_timer = $attack_4_timer
@onready var attack_1_hitbox_timer = $attack_1_hitbox_timer
@onready var attack_2_hitbox_timer = $attack_2_hitbox_timer
@onready var attack_3_hitbox_timer = $attack_3_hitbox_timer
@onready var attack_4_hitbox_timer = $attack_4_hitbox_timer
@onready var attack_1_2_box = $DamagePlayer/attack_1_2_box
@onready var attack_3_hitbox = $DamagePlayer/attack_3_hitbox
@onready var attack_4_hitbox = $DamagePlayer/attack_4_hitbox
@onready var attack_1_2_box_left = $DamagePlayer/attack_1_2_box_left
@onready var attack_3_hitbox_left = $DamagePlayer/attack_3_hitbox_left
@onready var attack_4_hitbox_left = $DamagePlayer/attack_4_hitbox_left
var running_to_player = false
@onready var sword_swing_1 = $sword_swing_1
@onready var sword_swing_2 = $sword_swing_2
@onready var sword_swing_3 = $sword_swing_3
@onready var sword_swing_4 = $sword_swing_4

# roll variables
var roll_direction = Vector2(0,0)
@onready var roll_timer = $roll_timer
@onready var body_damage_hb = $DamagePlayer/body_damage_hb
@onready var player_collision_box = $collision_with_player/player_collision_box
@onready var extend_hitbox = $extend_hitbox
var can_roll = true
@onready var rolling_sound = $rolling_sound

# jump attack variables
@onready var jump_timer = $jump_timer
@onready var fall_timer = $fall_timer
@onready var landing_timer = $landing_timer
var running_near_player = false
@onready var land_hit_area = $DamagePlayer/land_hit_area
var jump_landing_direction = Vector2(0,0)
@onready var jump_attack_timer = $jump_attack_timer
@onready var wait_after_jump_attack = $wait_after_jump_attack
@onready var jump_attack_sound = $jump_attack_sound


# defines a random number generator
var rng = RandomNumberGenerator.new()

# basic enemy variables
var target_position
var current_direction : look_direction
var can_attack = false
var can_move = true
var current_state = state.idle
var next_attack = attack.quad
var room = null

# on start
func _ready():
	# basic enemy stats
	speed = 1.7
	health = 80
	max_health = health
	# sets references to the player and catalog
	catalog = Events.catalog
	player = Events.player
	# disables the enemy
	sleep()
	# resets the attack hitboxes
	reset_attack_hitboxes()

# defines the wake_up function needed for the lost knight
## this is called by the rooms when a player enters it
func wake_up():
	player_in_room = true
	# runs spawn_in()
	spawn_in()

# runs ever frame
func _process(delta):
	# if the state is healing
	if current_state == state.healing:
		# increase the health bar
		health += delta * max_health
		Events.hud.adjust_health_bar(health)

# called every frame
func _physics_process(_delta):
	# if the player is in the room, not dying, and not spawning
	if player_in_room && !dying && !spawning:
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && Engine.time_scale != 0.0 && current_state != state.healing:
			# gets the player's position and looks toward it
			player_position = player.get_player_position()
			target_position = (player_position - center_marker.global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# if the current state is rolling
			if current_state == state.rolling:
				# roll in the rolling direction
				move_and_collide(roll_direction.normalized() * get_speed() *1.2)
			# if the current state is jumping
			elif current_state == state.jump:
				# move in the jumping direction
				move_and_collide(jump_landing_direction.normalized() * get_speed())
			# if the lost knight can attack and the current state is not rolling
			elif can_attack && current_state != state.rolling:
				# does an attack
				do_attack()
			# if the lost knight is running to the player
			elif running_to_player:
				# gets the player's position and looks toward it
				if current_direction == look_direction.left :
					# plays the basic move animation and sets the playing_hit_animation to false
					animated_sprite.play("run_left")
					player_position = player.get_marker_right()
				## Move right
				else:
					animated_sprite.play("run_right")
					player_position = player.get_marker_left()
				# set the target position
				target_position = (player_position - center_marker.global_position).normalized()
				# is the knight is not close enough to the player to attack
				if center_marker.global_position.distance_to(player_position) > 18 && global_position.distance_to(player_position) > 10:
					### has to use get_speed() to move based on dusted effect
					# move the knight towards the player
					velocity = target_position.normalized() * get_speed() * 80
					move_and_slide()
				# is the knight is close enough to the player to attack
				else:
					# stop running
					running_to_player = false
					# do a quad attack
					quad_attack()
			# if the lost knight is running near the player
			elif running_near_player:
				# gets the player's position and looks toward it
				if current_direction == look_direction.left :
					# plays the basic move animation and sets the playing_hit_animation to false
					animated_sprite.play("run_left")
				## Move right
				else:
					animated_sprite.play("run_right")
				# get the player's position and target that
				player_position = player.get_player_position()
				target_position = (player_position - global_position).normalized()
				# if the knight is not close enough to jump
				if global_position.distance_to(player_position) > 35:
					### has to use get_speed() to move based on dusted effect
					# move toward the player
					velocity = target_position.normalized() * get_speed()* 80
					move_and_slide()
				# if the knight is close enough to jump
				else:
					# stop running near the player
					running_near_player = false
					# do a jump attack
					jump_attack()
			# if the knight is idle
			elif current_state == state.idle:
				# flips the direction of the lost knight based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				if current_direction == look_direction.left :
					# plays the basic move animation and sets the playing_hit_animation to false
					animated_sprite.play("idle_left")
				## Move right
				elif current_direction == look_direction.right:
					animated_sprite.play("idle_right")

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage, attack_identifer, is_effect):
	# if the knight is healing or rolling, ignore damage
	if current_state == state.healing || current_state == state.rolling :
		pass
	else:
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
				# if the knight can heal
				if can_heal:
					# plays the hit sound
					hit_sound.play()
					# reset the states
					reset_states()
					# start the idle until heal timer
					idle_until_heal.start()
				else:
					# sets the enemy's state to dying
					dying = true
					# starts the death animation timer
					death_timer.start()
					# plays the death animation
					if current_direction == look_direction.right:
						animated_sprite.play("dying_right")
					else:
						animated_sprite.play("dying_left")
					# start the death sound timer
					death_sound_timer.start()
					# remove the damage player hitbox
					damage_player.queue_free()
					remove_hitbox()

# when death sound timer ends
func _on_death_sound_timer_timeout():
	# play the death sound
	death_sound.play()

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the death timer runs out
func _on_death_timer_timeout():
	# hide the health bar
	Events.hud.hide_health_bar()
	# unlock the enemy in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.lost_knight)
	# clears the room (this is a fix to a bug with the lost knight
	player.cleared_room_called_from_enemy()
	# call enemy_slain()
	enemy_slain()

# when spawning in
func spawn_in():
	# set the lost knight state to spawning
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
	# show the lost knight's health bar in the HUD
	Events.hud.set_health_bar(max_health, "Lost Knight")
	# start the attack timer
	attack_timer.start()

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the lost knight to attack
	can_attack = true
	# allow the knight to roll
	can_roll = true

# when the short attack timer ends
func _on_short_attack_timer_timeout():
	# allow the lost knight to attack
	can_attack = true
	# allow the knight to roll
	can_roll = true

# when the lost knight is doing a random attack
func do_attack():
	# checks to make sure the character isn't dying
	if !dying:
		# disable attacks
		can_attack = false
		# start the correct attack
		if next_attack == attack.quad:
			run_to_player()
		elif next_attack == attack.jump:
			run_near_player()

# when the attacks end
func attack_end():
	# set the state to idle and start the attack timer
	if current_state == state.attack:
		attack_timer.start()
	elif current_state == state.jump_attack:
		short_attack_timer.start()
	current_state = state.idle

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null

# resets the states for the knight
func reset_states():
	current_state = state.idle
	next_attack = attack.quad
	can_roll = false
	can_attack = false
	running_near_player = false
	running_to_player = false
	if current_direction == look_direction.right:
		animated_sprite.play("idle_right")
	else:
		animated_sprite.play("idle_left")

# when the idle until healing timer ends
func _on_idle_until_heal_timeout():
	# heal
	heal()

# heal the lost knight
func heal():
	# plays the correct animation
	if current_direction == look_direction.right:
		animated_sprite.play("heal_right")
	else:
		animated_sprite.play("heal_left")
	# sets the state to healing
	current_state = state.healing
	# starts the heal timer
	heal_timer.start()
	# disables healing
	can_heal = false
	# set that healing is true
	healing = true
	# start the heal sound timer
	heal_sound_timer.start()

# when the heal sound timer
func _on_heal_sound_timer_timeout():
	# play the heal sound
	heal_sound.play()

# when the heal timer ends
func _on_heal_timer_timeout():
	# set the health to max
	health = max_health
	Events.hud.adjust_health_bar(health)
	# disable healing
	healing = false
	# resets the states
	reset_states()
	# start the short attack timer
	short_attack_timer.start()

# makes the knight run to the player
func run_to_player():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		running_to_player = true
		current_state = state.running

# does a quadruple sword attack
func quad_attack():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# sets the state to an attack
		current_state = state.attack
		# disables movement
		can_move = false
		# set the next attack to a jump attack
		next_attack = attack.jump
		# plays the correct animation
		if current_direction == look_direction.right:
			animated_sprite.play("quad_attack_right")
		else:
			animated_sprite.play("quad_attack_left")
		# starts the attack timers
		quad_attack_timer.start()
		attack_1_timer.start()
		attack_2_timer.start()
		attack_3_timer.start()
		attack_4_timer.start()

# when the quad attack timer ends
func _on_quad_attack_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# reset the attack hitboxes
		reset_attack_hitboxes()
		# end the attack
		attack_end()

# resets the attack hitboxes
func reset_attack_hitboxes():
	attack_1_2_box.set_deferred("disabled", true)
	attack_3_hitbox.set_deferred("disabled", true)
	attack_4_hitbox.set_deferred("disabled", true)
	attack_1_2_box_left.set_deferred("disabled", true)
	attack_3_hitbox_left.set_deferred("disabled", true)
	attack_4_hitbox_left.set_deferred("disabled", true)

# when the attack 1 timer ends
func _on_attack_1_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# enable the correct attack hitbox
		if current_direction == look_direction.right:
			attack_1_2_box.set_deferred("disabled", false)
		else:
			attack_1_2_box_left.set_deferred("disabled", false)
		# start the attack hitbox timer
		attack_1_hitbox_timer.start()
		# play the sword swing sound
		sword_swing_1.play()

# when the attack 1 hitbox timer ends
func _on_attack_1_hitbox_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# disable the correct hitbox
		if current_direction == look_direction.right:
			attack_1_2_box.set_deferred("disabled", true)
		else:
			attack_1_2_box_left.set_deferred("disabled", true)

# when the attack 2 timer ends
func _on_attack_2_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# enable the correct attack hitbox
		if current_direction == look_direction.right:
			attack_1_2_box.set_deferred("disabled", false)
		else:
			attack_1_2_box_left.set_deferred("disabled", false)
		# start the attack hitbox timer
		attack_2_hitbox_timer.start()
		# play the sword swing sound
		sword_swing_2.play()

# when the attack 2 hitbox timer ends
func _on_attack_2_hitbox_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# disable the correct hitbox
		if current_direction == look_direction.right:
			attack_1_2_box.set_deferred("disabled", true)
		else:
			attack_1_2_box_left.set_deferred("disabled", true)

# when the attack 3 timer ends
func _on_attack_3_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# enable the correct attack hitbox
		if current_direction == look_direction.right:
			attack_3_hitbox.set_deferred("disabled", false)
		else:
			attack_3_hitbox_left.set_deferred("disabled", false)
		# start the attack hitbox timer
		attack_3_hitbox_timer.start()
		# play the sword swing sound
		sword_swing_3.play()

# when the attack 3 hitbox timer ends
func _on_attack_3_hitbox_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# disable the correct hitbox
		if current_direction == look_direction.right:
			attack_3_hitbox.set_deferred("disabled", true)
		else:
			attack_3_hitbox_left.set_deferred("disabled", true)

# when the attack 4 timer ends
func _on_attack_4_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# enable the correct attack hitbox
		if current_direction == look_direction.right:
			attack_4_hitbox.set_deferred("disabled", false)
		else:
			attack_4_hitbox_left.set_deferred("disabled", false)
		# start the attack hitbox timer
		attack_4_hitbox_timer.start()
		# play the sword swing sound
		sword_swing_4.play()

# when the attack 4 hitbox timer ends
func _on_attack_4_hitbox_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# disable the correct hitbox
		if current_direction == look_direction.right:
			attack_4_hitbox.set_deferred("disabled", true)
		else:
			attack_4_hitbox_left.set_deferred("disabled", true)

# when the knife detection area is entered
func _on_knife_detection_area_entered(area):
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# if the area is a knife
		if area is Knife:
			# if the knight can roll
			if current_state == state.idle && can_roll:
				# roll
				roll()

# rolls in a random direction
func roll():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# diable rolling
		can_roll = false
		# gets a random direction
		## x direction
		var vec_x = rng.randf_range(0.1, 1)
		var pos_or_neg = rng.randi_range(-1, 1)
		if pos_or_neg != 0:
			vec_x = pos_or_neg * vec_x
		## y direction
		var vec_y = rng.randf_range(0.1, 1)
		pos_or_neg = rng.randi_range(-1, 1)
		if pos_or_neg != 0:
			vec_y = pos_or_neg * vec_y
		# normalize the movement vector
		roll_direction = Vector2(vec_x, vec_y).normalized()
		# plays the correct animation
		if current_direction == look_direction.left:
			animated_sprite.play("roll_left")
		else:
			animated_sprite.play("roll_right")
		# set the state to rolling
		current_state = state.rolling
		# plays the rolling sound
		rolling_sound.play()
		# start the roll timer
		roll_timer.start()
		# disable hitboxes
		body_damage_hb.set_deferred("disabled", true)
		player_collision_box.set_deferred("disabled", false)
		extend_hitbox.set_deferred("disabled", true)

# when the roll timer ends
func _on_roll_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# set state to idle
		current_state = state.idle
		# reset the hitboxes
		body_damage_hb.set_deferred("disabled", false)
		player_collision_box.set_deferred("disabled", false)
		extend_hitbox.set_deferred("disabled", false)

# makes the knight run near the player
func run_near_player():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		running_near_player = true
		current_state = state.running

# does a jump attack
func jump_attack():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# set the next attack
		next_attack = attack.quad
		# sets the jump landing direction
		jump_landing_direction = target_position.normalized()
		# sets the current state to jumping
		current_state = state.jump
		# plays the correct animation
		if current_direction == look_direction.right:
			animated_sprite.play("jump_attack_right")
		else:
			animated_sprite.play("jump_attack_left")
		# starts the jump attack timers
		jump_timer.start()
		landing_timer.start()
		fall_timer.start()
		jump_attack_timer.start()
		# sets the hitboxes
		body_damage_hb.set_deferred("disabled", true)
		player_collision_box.set_deferred("disabled", true)
		extend_hitbox.set_deferred("disabled", false)

# when the jump timer ends
func _on_jump_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# adjust the hitboxes
		hitbox.set_deferred("disabled", true)
		# play the jump attack sound
		jump_attack_sound.play()
		# set the state to jump attack
		current_state = state.jump_attack
		# disables movement
		can_move = false

# when the fall timer ends
func _on_fall_timer_timeout():
	pass

# when the landing timer ends
func _on_landing_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# adjust the hitboxes
		land_hit_area.set_deferred("disabled", false)

# when the jump attack timer ends
func _on_jump_attack_timer_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# adjust the hitboxes
		hitbox.set_deferred("disabled", false)
		# start the wait after jump attack timer
		wait_after_jump_attack.start()
		# end the attack
		attack_end()

# when the wait after jump attack timer ends
func _on_wait_after_jump_attack_timeout():
	# checks to make sure the character isn't dying or healing
	if !dying && !healing:
		# resets the hitboxes
		player_collision_box.set_deferred("disabled", false)
		land_hit_area.set_deferred("disabled", true)
		extend_hitbox.set_deferred("disabled", false)

# removes the enemy's hitboxes
func remove_hitbox():
	damage_player.queue_free()
