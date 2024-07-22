extends Enemy

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
const FIRE_BALL = preload("res://Scenes/enemies/fire_ball/fire_ball.tscn")
@onready var attack_animation_timer = $attack_animation_timer
@onready var fire_ball_offset = $fire_ball_offset
@onready var flap_sound = $flap_sound
@onready var flap_sound_timer = $flap_sound_timer

# attack variables
var can_attack = false
var can_attack_timer_max = 5
var can_attack_timer_range = 1.5
var can_attack_timer = can_attack_timer_max - can_attack_timer_range
var attacking = false

# defines a random number generator
var rng = RandomNumberGenerator.new()

# general enemy variables
var target_position
var current_direction : look_direction
var can_move = true

# sets the enemy's stats and references
func _ready():
	speed = 0.6
	health = 25
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

## on every frame
func _process(delta):
	if player_in_room:
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
	# if the player is in the room, the tiny_devil isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.get_player_position()
			target_position = (player_position - animated_sprite.global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# if the tiny_devil can attack and is further than 30 pixels
			if can_attack == true:
				attack()
			# else if the tiny_devil can move
			elif can_move:
				# look in the direction of the player
				# flips the direction of the tiny_devil based on the current_direction
				## NOTE: all these checks are identical but change the directions they look at
				## Move left
				if current_direction == look_direction.left :
					animated_sprite.play("move_left")
				## Move right
				elif current_direction == look_direction.right:
					animated_sprite.play("move_right")
				if animated_sprite.global_position.distance_to(player_position) > 5:
					## has to use get_speed() to move based on dusted effect
					move_and_collide(target_position.normalized() * get_speed())
	# if the player is in the room
	if player_in_room:
		# play the flap sound on the correct frame of each animation
		if animated_sprite.animation == "spawning":
			if animated_sprite.frame == 2:
				flap_sound.play()
		elif animated_sprite.animation == "move_left" || animated_sprite.animation == "move_right":
			if animated_sprite.frame == 1:
				flap_sound.play()
		elif animated_sprite.animation == "attack_left" || animated_sprite.animation == "attack_right":
			if animated_sprite.frame == 0 || animated_sprite.frame == 4:
				flap_sound.play()

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
	# unlock the tiny_devil in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.tiny_devil)
	# call enemy slain
	enemy_slain()

# when spawn timer ends
func _on_spawn_timer_timeout():
	spawning = false

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when the tiny_devil attacks
func attack():
	# play the correct animation for the attack
	if current_direction == look_direction.right:
		animated_sprite.play("attack_right")
	else:
		animated_sprite.play("attack_left")
	# start the attack timers
	attack_animation_timer.start()
	fire_ball_offset.start()
	# disable movement
	can_move = false

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null

# when the attack animation timer ends
func _on_attack_animation_timer_timeout():
	# set a random value until the next attack
	can_attack_timer = rng.randf_range(can_attack_timer_max - 0.5, can_attack_timer_max + 0.5)
	# disable attacks
	can_attack = false
	# enable movement
	can_move = true

# when the fire ball offset timer ends
func _on_fire_ball_offset_timeout():
	# if the enemy is not dying
	if !dying:
		# spawn a fire ball
		var fire_ball = FIRE_BALL.instantiate()
		fire_ball.global_position = animated_sprite.global_position
		get_tree().current_scene.add_child(fire_ball)
		# tell the fire ball that it spawned
		fire_ball.spawned((player.get_player_position() - animated_sprite.global_position).normalized())
