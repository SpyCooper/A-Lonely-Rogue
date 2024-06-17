extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_timer = $death_timer
@onready var death_sound = $DeathSound
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_timer = $Spawn_timer

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

# variables
var can_move = true
var playing_hit_animation = false

# sets the enemy's stats and references
func _ready():
	speed = 0.0
	health = 15
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
	
	attack_wait_timer.start()

# called every frame
func _physics_process(_delta):
	# if the player is in the room, the skeleton mage isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# look in the direction of the player
			# flips the direction of the skeleton archer based on the current_direction
			## NOTE: all these checks are identical but change the directions they look at
			## Move left
			if current_direction == look_direction.left :
				# if any of the hit animations are playing
				if animated_sprite.animation == "hit_right":
					# switch to the same frame of the hit animation in the new direction
					# this keeps hit animations running for the same duration
					var frame = animated_sprite.frame
					animated_sprite.play("hit_left")
					animated_sprite.frame = frame
				# if a hit animation is not actively playing a hit animation
				elif playing_hit_animation != true || animated_sprite.is_playing() == false:
					# plays the basic move animation and sets the playing_hit_animation to false
					animated_sprite.play("summoning_left")
					playing_hit_animation = false
			## Move right
			elif current_direction == look_direction.right:
				if animated_sprite.animation == "hit_left":
					var frame = animated_sprite.frame
					animated_sprite.play("hit_right")
					animated_sprite.frame = frame
				elif playing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("summoning_right")
					playing_hit_animation = false
			# if the enemy can attack
			if can_attack:
				# attack
				attack()

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	# checks if the skeleton mage is not spawning or dying
	if spawning == false && dying == false:
		# subtracts the health
		health -= damage
		# if health is greater than 0
		if health > 0:
			# play the hit animation based on the look direction
			if current_direction == look_direction.left:
				animated_sprite.play("hit_left")
			elif current_direction == look_direction.right:
				animated_sprite.play("hit_right")
			# set the playing_hit_animation to true
			playing_hit_animation = true
			# play the hit sound
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

# when the enemy attacks
func attack():
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
	attack_wait_timer.start()

# when attack wait timer ends
func _on_attack_wait_timer_timeout():
	# set can attack to true
	can_attack = true

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite
