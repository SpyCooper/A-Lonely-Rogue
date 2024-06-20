extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_timer = $death_timer
@onready var death_sound = $DeathSound
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_timer = $Spawn_timer

# attack variables
var is_idle = false
var can_attack = false
var can_attack_timer_max = 1.0
var can_attack_timer = can_attack_timer_max
var attacking = false
@onready var attack_animation_timer = $attack_animation_timer
@onready var attack_sound = $attack_sound
const ARROW = preload("res://Scenes/enemies/arrow/arrow.tscn")
@onready var arrow_spawn_timer = $arrow_spawn_timer

# general enemy variables
var target_position
var current_direction : look_direction

# variables
var can_move = true
var playing_hit_animation = false

# sets the enemy's stats and references
func _ready():
	speed = .7
	health = 20
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog

# on the enemy wakes up
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
	# if the skeleton cannot attack
	if !can_attack:
		# decrement the attack timer
		can_attack_timer -= delta
		# if the attack timer is less than or equal to 0
		if can_attack_timer <= 0:
			# set can attack to true
			can_attack = true

# called every frame
func _physics_process(_delta):
	# if the player is in the room, the skeleton archer isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			# if the enemy can attack and is less than 100 pixels away from the player
			if can_attack && position.distance_to(player_position) < 100:
				attack()
			# if the enemy is further than 100 pixels
			elif position.distance_to(player_position) >= 100:
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
						animated_sprite.play("move_left")
						playing_hit_animation = false
						is_idle = false
				## Move right
				elif current_direction == look_direction.right:
					if animated_sprite.animation == "hit_left":
						var frame = animated_sprite.frame
						animated_sprite.play("hit_right")
						animated_sprite.frame = frame
					elif playing_hit_animation != true || animated_sprite.is_playing() == false:
						animated_sprite.play("move_right")
						playing_hit_animation = false
						is_idle = false
				
				is_idle = false
				## has to use get_speed() to move based on dusted effect
				move_and_collide(target_position.normalized() * get_speed())
			# if the enemy is not attacking
			elif !attacking:
				# play the idle left or right animation
				if current_direction == look_direction.left:
					# if a hit animation is playing
					if animated_sprite.animation == "hit_right" || animated_sprite.animation == "hit_idle_right" || animated_sprite.animation == "attack_hit_left" || animated_sprite.animation == "attack_hit_right" || animated_sprite.animation == "hit_left":
						# play the frame of the hit animation for the current direction
						var frame = animated_sprite.frame
						animated_sprite.play("hit_idle_left")
						animated_sprite.frame = frame
					# if a hit animation is not playing
					elif playing_hit_animation != true || animated_sprite.is_playing() == false:
						# play idle left
						animated_sprite.play("idle_left")
						is_idle = true
				elif current_direction == look_direction.right:
					if animated_sprite.animation == "hit_left" || animated_sprite.animation == "hit_idle_left" || animated_sprite.animation == "attack_hit_left" ||animated_sprite.animation == "attack_hit_right" || animated_sprite.animation == "hit_right":
						var frame = animated_sprite.frame
						animated_sprite.play("hit_idle_right")
						animated_sprite.frame = frame
					elif playing_hit_animation != true || animated_sprite.is_playing() == false:
						animated_sprite.play("idle_right")
						is_idle = true


# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	# checks if the skeleton archer is not spawning or dying
	if spawning == false && dying == false:
		# subtracts the health
		health -= damage
		# if health is greater than 0
		if health > 0:
			# play the hit animation based on the look direction
			if current_direction == look_direction.left:
				# if attacking
				if attacking:
					# play the frame of the hit animation for the current direction
					var frame = animated_sprite.frame
					animated_sprite.frame = frame
					animated_sprite.play("attack_hit_left")
				# if the enemy is idle
				elif is_idle:
					animated_sprite.play("hit_idle_left")
				# else play hit left
				else:
					var frame = animated_sprite.frame
					animated_sprite.frame = frame
					animated_sprite.play("hit_left")
			elif current_direction == look_direction.right:
				if attacking:
					var frame = animated_sprite.frame
					animated_sprite.frame = frame
					animated_sprite.play("attack_hit_right")
				elif is_idle:
					animated_sprite.play("hit_idle_right")
				else:
					var frame = animated_sprite.frame
					animated_sprite.frame = frame
					animated_sprite.play("hit_right")
			# set the playing_hit_animation to true
			playing_hit_animation = true
			# play the hit sound
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

# when death timer ends
func _on_death_timer_timeout():
	# unlock the skeleton archer in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.skeleton_archer)
	# call enemy slain
	enemy_slain()

# when spawn timer ends
func _on_spawn_timer_timeout():
	spawning = false

# when the enemy attacking
func attack():
	# set bool values
	can_attack = false
	can_move = false
	attacking = true
	# reset can attack timer
	can_attack_timer = can_attack_timer_max
	# play the attack animation for the current direction
	if current_direction == Enemy.look_direction.right:
		animated_sprite.play("attack_right")
	elif current_direction == Enemy.look_direction.left:
		animated_sprite.play("attack_left")
	# play the attack animation timer
	attack_animation_timer.start()
	# play the arrow spawn timer
	arrow_spawn_timer.start()

# when the attack animation timer ends
func _on_attack_animation_timer_timeout():
	# set can move and attacking
	can_move = true
	attacking = false

# when the arrow spawn timer ends
func _on_arrow_spawn_timer_timeout():
	# play the attack sound
	attack_sound.play()
	# get the player position
	player_position = player.position
	target_position = (player_position - global_position).normalized()
	# spawn the arrow
	var arrow = ARROW.instantiate()
	get_parent().add_child(arrow)
	# set the arrow's position
	arrow.global_position = global_position
	# tell the arrow that it's spawned
	arrow.spawned(target_position)

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# when called, the player and the enemy are considered to be in the same room
func spawned_in_room():
	player_in_room = true
	spawning = false
