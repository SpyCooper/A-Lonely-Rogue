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

# attack variables
var can_attack = false
@onready var attack_animation_timer = $attack_animation_timer
@onready var attack_sound = $attack_sound
@onready var summoning_circle_animated_sprite = $Summoning_circle/summoning_circle_animated_sprite
@onready var summoning_circle = $Summoning_circle
const SHADOW_BOLT = preload("res://Scenes/enemies/shadow_bolt/shadow_bolt.tscn")
@onready var attack_wait_timer = $attack_wait_timer

# general enemy variables
var target_position
var current_direction : look_direction

# defines a random number generator
var rng = RandomNumberGenerator.new()
var attack_wait_timer_duration = 1.0
var attack_wait_timer_duration_range = 0.5

# variables
var can_move = true

# sets the enemy's stats and references
func _ready():
	speed = 0.0
	health = 13
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

# called every frame
func _physics_process(_delta):
	# if the player is in the room, the skeleton mage isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.get_player_position()
			target_position = (player_position - animated_sprite.global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# look in the direction of the player
			# flips the direction of the skeleton archer based on the current_direction
			## NOTE: all these checks are identical but change the directions they look at
			## Move left
			if current_direction == look_direction.left :
				# plays the basic move animation and sets the playing_hit_animation to false
				animated_sprite.play("summoning_left")
			## Move right
			elif current_direction == look_direction.right:
				animated_sprite.play("summoning_right")
			# if the enemy can attack
			if can_attack:
				# attack
				attack()

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
			summoning_circle_animated_sprite.hide()
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
	# unlock the skeleton mage in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.skeleton_mage)
	# call enemy slain
	enemy_slain()

# when spawn timer ends
func _on_spawn_timer_timeout():
	# set spawning to false
	spawning = false
	# show the summoning circle animated sprite
	summoning_circle_animated_sprite.show()
	# start the attack wait timer
	attack_wait_timer.start(rng.randf_range(attack_wait_timer_duration-attack_wait_timer_duration_range, attack_wait_timer_duration+attack_wait_timer_duration_range))

# when the enemy attacks
func attack():
	# checks to make sure the character isn't dying
	if !dying:
		# play the attack sound
		attack_sound.play()
		# set can attack to false
		can_attack = false
		# spawn the shadow bolt
		var shadow_bolt = SHADOW_BOLT.instantiate()
		shadow_bolt.position = summoning_circle.position
		add_child(shadow_bolt)
		# tell the shadow bolt that it spawned
		shadow_bolt.spawned(self, true)

# when shadow bolt gone is called by a shadow bolt
func shadow_bolt_gone():
	# play attack wait timer
	attack_wait_timer.start(rng.randf_range(attack_wait_timer_duration-attack_wait_timer_duration_range, attack_wait_timer_duration+attack_wait_timer_duration_range))

# when attack wait timer ends
func _on_attack_wait_timer_timeout():
	# set can attack to true
	can_attack = true

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when called, the player and the enemy are considered to be in the same room
func spawned_in_room():
	# show the summoning circle animated sprite
	summoning_circle_animated_sprite.show()
	attack_wait_timer.start(rng.randf_range(attack_wait_timer_duration-attack_wait_timer_duration_range, attack_wait_timer_duration+attack_wait_timer_duration_range))
	player_in_room = true
	spawning = false

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null
