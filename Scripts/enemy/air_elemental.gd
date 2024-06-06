extends Enemy

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var death_timer = $death_timer
@onready var death_sound = $DeathSound
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var spawn_timer = $Spawn_timer

# throw tornado variables
var can_throw = false
var thrown = false
var throw_timer_max = 3.5
var throw_timer = throw_timer_max
var thrown_counter = 0
const TORNADO = preload("res://Scenes/enemies/tornado/tornado.tscn")
@onready var time_between_attacks_timer = $time_between_attacks_timer

# general enemy variables
var target_position
var current_direction : look_direction

# variables
var can_move = true
var playing_hit_animation = false

# sets the enemy's stats and references
func _ready():
	speed = .7
	health = 10
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog

func wake_up():
	# player is now in the room
	player_in_room = true
	# the spawn animation is played
	animated_sprite.play("spawning")
	# the spawn_timer is started
	spawn_timer.start()
	# the spawn sound in played
	spawn_sound.play()

# every frame
func _process(delta):
	# determine if the elemental can throw or not
	if !can_throw && !dying && !spawning:
		throw_timer -= delta
	if throw_timer <= 0:
		can_throw = true

# called every frame
func _physics_process(_delta):
	# if the player is in the room, the air elemental isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			
			# flips the direction of the air elemental based on the current_direction
			## NOTE: all these checks are identical but change the directions they look at
			## Move left
			if current_direction == look_direction.left :
				# if any of the hit animations are playing
				if animated_sprite.animation == "hit_right" || animated_sprite.animation == "hit_up" || animated_sprite.animation == "hit_down" :
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
			## Move right
			elif current_direction == look_direction.right:
				if animated_sprite.animation == "hit_left" || animated_sprite.animation == "hit_up" || animated_sprite.animation == "hit_down":
					var frame = animated_sprite.frame
					animated_sprite.play("hit_right")
					animated_sprite.frame = frame
				elif playing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("move_right")
					playing_hit_animation = false
			
			if can_throw:
				# reset the throw
				can_throw = false
				throw_timer = throw_timer_max
				throw_tornado()
			elif position.distance_to(player_position) > 60:
				move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	# checks if the air elemental is not spawning or dying
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
	# unlock the air elemental in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.air_elemental)
	# call enemy slain
	enemy_slain()

# when spawn timer ends
func _on_spawn_timer_timeout():
	spawning = false

func throw_tornado():
	player_position = player.position
	target_position = (player_position - global_position).normalized()
	# create and spawn the rock to move toward the player's direction
	var tornado = TORNADO.instantiate()
	get_parent().add_child(tornado)
	tornado.global_position = global_position
	tornado.spawned(target_position, current_direction)
	thrown_counter += 1
	time_between_attacks_timer.start()

func _on_time_between_attacks_timer_timeout():
	if thrown_counter < 3:
		throw_tornado()
	else:
		thrown_counter = 0
