extends Enemy

# sets the enemies state
enum state
{
	attack,
	healing,
	jump,
	jump_attack,
	rolling,
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
@onready var center_marker = $center_marker

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_sound_timer = $Spawn_sound_timer
@onready var attack_sound = $attack_sound
@onready var death_sound = $death_sound

# heal variables
var can_heal = true
@onready var heal_timer = $heal_timer

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

# roll variables
var roll_direction = Vector2(0,0)
@onready var roll_timer = $roll_timer
@onready var body_damage_hb = $DamagePlayer/body_damage_hb
@onready var player_collision_box = $collision_with_player/player_collision_box



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
	speed = 1.5
	health = 10
	max_health = health
	# sets references to the player and catalog
	catalog = Events.catalog
	player = Events.player
	# disables the enemy
	sleep()
	
	reset_attack_hitboxes()

# defines the wake_up function needed for the onyx demon
## this is called by the rooms when a player enters it
func wake_up():
	player_in_room = true
	# runs spawn_in()
	spawn_in()

func _process(delta):
	if current_state == state.healing:
		health += delta * max_health
		hud.adjust_health_bar(health)

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
			
			if current_state == state.rolling:
				move_and_collide(roll_direction.normalized() * get_speed())
			elif can_attack:
				# does an attack
				attack()
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
				target_position = (player_position - center_marker.global_position).normalized()
				
				if center_marker.global_position.distance_to(player_position) > 12:
					### has to use get_speed() to move based on dusted effect
					var collision = move_and_collide(target_position.normalized() * get_speed())
					if collision != null:
						running_to_player = false
						quad_attack()
				else:
					running_to_player = false
					quad_attack()
			elif current_state == state.idle:
				# flips the direction of the onyx demon based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					# plays the basic move animation and sets the playing_hit_animation to false
					animated_sprite.play("idle_left")
				## Move right
				elif current_direction == look_direction.right:
					animated_sprite.play("idle_right")
				
				### NOTE: the onyx demon cannot move currently but this is here just in case this is changes
				## moves the onyx demon to a distance of 15 to the player
				#if position.distance_to(player_position) > 15:
					### has to use get_speed() to move based on dusted effect
					#move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage, attack_identifer, is_effect):
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
				if can_heal:
					heal()
				else:
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
	catalog.unlock_enemy(EnemyTypes.enemy.lost_knight)
	# call enemy_slain()
	enemy_slain()

# when spawning in
func spawn_in():
	# set the onyx demon state to spawning
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
	# show the onyx demon's health bar in the HUD
	hud.set_health_bar(max_health, "Lost Knight")
	# start the attack timer
	attack_timer.start()

# when the attack timer ends
func _on_attack_timer_timeout():
	# allow the onyx demon to attack
	can_attack = true

# when the onyx demon is doing a random attack
func attack():
	# checks to make sure the character isn't dying
	if !dying:
		can_attack = false
		
		#run_to_player()
		roll()

# when the attacks end
func attack_end():
	# set the state to idle and start the attack timer
	current_state = state.idle
	attack_timer.start()

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null

func heal():
	if current_direction == look_direction.right:
		animated_sprite.play("heal_right")
	else:
		animated_sprite.play("heal_left")
	current_state = state.healing
	heal_timer.start()
	can_heal = false

func _on_heal_timer_timeout():
	health = max_health
	hud.adjust_health_bar(health)
	current_state = state.idle

func run_to_player():
	running_to_player = true

func quad_attack():
	current_state = state.attack
	can_move = false
	quad_attack_timer.start()
	
	if current_direction == look_direction.right:
		animated_sprite.play("quad_attack_right")
	else:
		animated_sprite.play("quad_attack_left")
	
	attack_1_timer.start()
	attack_2_timer.start()
	attack_3_timer.start()
	attack_4_timer.start()

func _on_quad_attack_timer_timeout():
	reset_attack_hitboxes()
	attack_end()

func reset_attack_hitboxes():
	attack_1_2_box.set_deferred("disabled", true)
	attack_3_hitbox.set_deferred("disabled", true)
	attack_4_hitbox.set_deferred("disabled", true)
	
	attack_1_2_box_left.set_deferred("disabled", true)
	attack_3_hitbox_left.set_deferred("disabled", true)
	attack_4_hitbox_left.set_deferred("disabled", true)

func _on_attack_1_timer_timeout():
	if current_direction == look_direction.right:
		attack_1_2_box.set_deferred("disabled", false)
	else:
		attack_1_2_box_left.set_deferred("disabled", false)
	attack_1_hitbox_timer.start()

func _on_attack_1_hitbox_timer_timeout():
	if current_direction == look_direction.right:
		attack_1_2_box.set_deferred("disabled", true)
	else:
		attack_1_2_box_left.set_deferred("disabled", true)

func _on_attack_2_timer_timeout():
	if current_direction == look_direction.right:
		attack_1_2_box.set_deferred("disabled", false)
	else:
		attack_1_2_box_left.set_deferred("disabled", false)
	attack_2_hitbox_timer.start()

func _on_attack_2_hitbox_timer_timeout():
	if current_direction == look_direction.right:
		attack_1_2_box.set_deferred("disabled", true)
	else:
		attack_1_2_box_left.set_deferred("disabled", true)

func _on_attack_3_timer_timeout():
	if current_direction == look_direction.right:
		attack_3_hitbox.set_deferred("disabled", false)
	else:
		attack_3_hitbox_left.set_deferred("disabled", false)
	attack_3_hitbox_timer.start()

func _on_attack_3_hitbox_timer_timeout():
	if current_direction == look_direction.right:
		attack_3_hitbox.set_deferred("disabled", true)
	else:
		attack_3_hitbox_left.set_deferred("disabled", true)

func _on_attack_4_timer_timeout():
	if current_direction == look_direction.right:
		attack_4_hitbox.set_deferred("disabled", false)
	else:
		attack_4_hitbox_left.set_deferred("disabled", false)
	attack_4_hitbox_timer.start()

func _on_attack_4_hitbox_timer_timeout():
	if current_direction == look_direction.right:
		attack_4_hitbox.set_deferred("disabled", true)
	else:
		attack_4_hitbox_left.set_deferred("disabled", true)

func roll():
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
	if current_direction == look_direction.left:
		animated_sprite.play("roll_left")
	else:
		animated_sprite.play("roll_right")
	
	current_state = state.rolling
	
	roll_timer.start()
	body_damage_hb.set_deferred("disabled", true)
	player_collision_box.set_deferred("disabled", true)

func _on_roll_timer_timeout():
	current_state = state.idle
	body_damage_hb.set_deferred("disabled", false)
	player_collision_box.set_deferred("disabled", false)
	attack_end()
