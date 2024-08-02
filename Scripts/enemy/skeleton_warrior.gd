extends Enemy

class_name skeleton_warrior

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_timer = $death_timer
@onready var death_sound = $DeathSound
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_timer = $Spawn_timer
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
const ENEMY_HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")
@onready var damage_player = $DamagePlayer

# attack variables
var can_attack = false
var can_attack_timer_max = 1.8
var can_attack_timer = can_attack_timer_max
var can_attack_timer_range = 0.5
var attacking = false
@onready var attack_animation_timer = $attack_animation_timer
const SLASH_PROJECTILE = preload("res://Scenes/enemies/slash_projectile/slash_projectile.tscn")
@onready var slash_projection_spawn_timer = $slash_projection_spawn_timer
@onready var attack_sound = $attack_sound

# general enemy variables
var target_position
var current_direction : look_direction

# defines a random number generator
var rng = RandomNumberGenerator.new()

# variables
var can_move = true
var is_idle = false

# sets the enemy's stats and references
func _ready():
	speed = .7
	health = 17
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
			target_position = (player_position - animated_sprite.global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# if the enemy can attack and is less than 50 pixels away from the player
			if can_attack && animated_sprite.global_position.distance_to(player_position) < 50:
				# attack
				attack()
			# if the enemy is further than 50 pixels
			elif animated_sprite.global_position.distance_to(player_position) >= 50:
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
	# unlock the skeleton warrior in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.skeleton_warrior)
	# call enemy slain
	enemy_slain()

# when spawn timer ends
func _on_spawn_timer_timeout():
	spawning = false

# when the enemy attacks
func attack():
	# checks to make sure the character isn't dying
	if !dying:
		# set bool variables
		can_attack = false
		can_move = false
		attacking = true
		# reset the can attack timer
		can_attack_timer = rng.randf_range(can_attack_timer_max-can_attack_timer_range, can_attack_timer_max+can_attack_timer_range)
		# play the attack left or right animation
		if current_direction == Enemy.look_direction.right:
			animated_sprite.play("attack_right")
		elif current_direction == Enemy.look_direction.left:
			animated_sprite.play("attack_left")
		# play the attack animation timer
		attack_animation_timer.start()
		# play the slash projection spawn timer
		slash_projection_spawn_timer.start()
		# play the attack sound
		attack_sound.play()

# when the attack animation timer
func _on_attack_animation_timer_timeout():
	# set can move to true
	can_move = true
	# set attack to false
	attacking = false

# when the slash projection spawn animation timer
func _on_slash_projection_spawn_timer_timeout():
	# checks to make sure the character isn't dying
	if !dying:
		# get the player position
		player_position = player.get_player_position()
		target_position = (player_position - animated_sprite.global_position).normalized()
		# spawn the clash projectile
		var slash = SLASH_PROJECTILE.instantiate()
		get_tree().current_scene.add_child(slash)
		# set the slash position
		slash.global_position = animated_sprite.global_position
		# tell the slash that it spawned
		slash.spawned(target_position)

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when called, the player and the enemy are considered to be in the same room
func spawned_in_room():
	player_in_room = true
	spawning = false

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null
