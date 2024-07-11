extends Enemy

# creates the class "slime" that other object can inherit from (specifically green_slime.gd)
class_name slime

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var spawn_timer = $Spawn_timer
@onready var death_timer = $death_timer
@onready var hit_sound = $HitSound
@onready var death_sound = $DeathSound
@onready var spawn_sound = $SpawnSound
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
const ENEMY_HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")
@onready var damage_player = $DamagePlayer

# general enemy variables
var target_position
var current_direction : look_direction

# sets the enemy's stats and references
func _ready():
	speed = .6
	health = 6
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog

# when the enemy is called to wake_up()
func wake_up():
	# player is now in the room
	player_in_room = true
	# the spawn animation is played
	animated_sprite.play("spawning")
	# the spawn_timer is started
	spawn_timer.start()
	# the spawn sound in played
	spawn_sound.play()

# called every frame
func _physics_process(_delta):
	# if the player is in the room, the slime isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		if player && Engine.time_scale != 0.0:
			# gets the target player position
			player_position = player.get_player_position()
			target_position = (player_position - animated_sprite.global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# flips the direction of the slime based on the if the target is on the left or right
			if current_direction == look_direction.left:
				# plays the basic move animation and sets the playing_hit_animation to false
				animated_sprite.play("look_left")
			elif current_direction == look_direction.right:
				animated_sprite.play("look_right")
			# moves the slime to the player with a distance of 10
			if animated_sprite.global_position.distance_to(player_position) > 5:
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

# return the animated sprite
func get_animated_sprite():
	return animated_sprite

# when called, the player and the slime are considered to be in the same room
func spawned_in_room():
	player_in_room = true
	spawning = false

# when the spawn timer ends, the state is no longer spawning
func _on_spawn_timer_timeout():
	spawning = false

# when the death timer ends
func _on_death_timer_timeout():
	# unlock the blue_slime in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.blue_slime)
	# call enemy slain
	enemy_slain()

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null
