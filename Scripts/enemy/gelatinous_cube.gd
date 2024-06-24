extends Enemy

# defines the spawn locations for slimes to use
enum spawn_location
{
	top,
	bottom,
	left,
	right
}

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var damage_player = $DamagePlayer
@onready var attack_timer = $Attack_timer
@onready var death_timer = $Death_timer
@onready var spawn_timer = $Spawn_timer
@onready var spawn_freeze_timer = $Spawn_freeze_timer
@onready var hud = %HUD

# defines variables used for the spawning of slimes
@onready var spawner_top = $Spawner_top
@onready var spawner_bottom = $Spawner_bottom
@onready var spawner_left = $Spawner_left
@onready var spawner_right = $Spawner_right
const GREEN_SLIME = preload("res://Scenes/enemies/green_slime.tscn")
@onready var animated_top = $animated_top
@onready var animated_bottom = $animated_bottom
@onready var animated_left = $animated_left
@onready var animated_right = $animated_right
@onready var wait_after_spawn_timer = $wait_after_spawn_timer

# sound effect references
@onready var hit_sound = $HitSound
@onready var spawn_sound = $SpawnSound
@onready var death_sound = $DeathSound
@onready var spawn_sound_timer = $Spawn_sound_timer

# defines a random number generator
var random_number_generator = RandomNumberGenerator.new()

# basic enemy variables
var target_position
var current_direction : look_direction
var playing_hit_animation = false
var can_attack = false
var can_move = true

# an array of slimes are spawning after spawning animation
var slime_to_be_spawned = []

# on start
func _ready():
	# basic enemy stats
	speed = 0.25
	health = 50
	max_health = health
	# sets references to the player and catalog
	catalog = Events.catalog
	player = Events.player
	# disables the enemy
	sleep()
	# hides slime spawning animations
	animated_bottom.hide()
	animated_left.hide()
	animated_right.hide()
	animated_top.hide()

# defines the wake_up function needed for the gel_cube
## this is called by the rooms when a player enters it
func wake_up():
	player_in_room = true
	# runs spawn_in()
	spawn_in()
	# starts the attack timer (used for spawning slime)
	attack_timer.start()

# called every frame
func _physics_process(_delta):
	# if the player is in the room, not dying, and not spawning
	if player_in_room && !dying && !spawning:
		# whenever the gelatinous cube can spawn slime, it will
		if can_attack:
			spawn_slimes()
		
		# if the player is in the room, the enemy can move, and the game isn't paused
		if player && can_move && Engine.time_scale != 0.0:
			# gets the player's position and looks toward it
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_look_direction(target_position)
			
			# flips the direction of the gelatinous cube based on the current_direction
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
			## Move up
			elif current_direction == look_direction.up:
				if animated_sprite.animation == "hit_left" || animated_sprite.animation == "hit_right" || animated_sprite.animation == "hit_down":
					var frame = animated_sprite.frame
					animated_sprite.play("hit_up")
					animated_sprite.frame = frame
				elif playing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("move_up")
					playing_hit_animation = false
			## Move down
			elif current_direction == look_direction.down:
				if animated_sprite.animation == "hit_left" || animated_sprite.animation == "hit_right" || animated_sprite.animation == "hit_up":
					var frame = animated_sprite.frame
					animated_sprite.play("hit_down")
					animated_sprite.frame = frame
				elif playing_hit_animation != true || animated_sprite.is_playing() == false:
					animated_sprite.play("move_down")
					playing_hit_animation = false
			
			# moves the gelatinous cube to a distance of 12 to the player
			if position.distance_to(player_position) > 12:
				## has to use get_speed() to move based on dusted effect
				move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage, attack_identifer):
	# checks if an attack with the identifier has hit
	var attack_can_hit = true
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
		# plays the hit sound if the HP after damage is > 0
		if health > 0:
			hit_sound.play()
		# adjust the boss health bar in the HUD
		hud.adjust_health_bar(health)
		# plays the hit animation based on the current direction
		if current_direction == look_direction.left:
			animated_sprite.play("hit_left")
		elif current_direction == look_direction.right:
			animated_sprite.play("hit_right")
		elif current_direction == look_direction.up:
			animated_sprite.play("hit_up")
		elif current_direction == look_direction.down:
			animated_sprite.play("hit_down")
		# sets the playing_hit_animation
		playing_hit_animation = true
		# checks if the enemy should be dead
		if health <= 0:
			# sets the enemy's state to dying
			dying = true
			# starts the death animation timer
			death_timer.start()
			# plays the death animation
			animated_sprite.play("death")
			# plays the death sound
			death_sound.play()

# returns the animated sprite
func get_animated_sprite():
	return animated_sprite

# spawns slimes
func spawn_slimes():
	# plays the spawn slime sound
	spawn_sound.play()
	# gets a random number of slimes between 1 and 3 (inclusive)
	var random_spawns = random_number_generator.randi_range(1, 3)
	# sets up spawn location that have been set
	var top_used = false;
	var bottom_used = false;
	var right_used = false;
	var left_used = false;
	# for each of the random spawns
	for spawn in random_spawns:
		# get a random spawn location out of the 4 direction
		var random_pos = random_number_generator.randi_range(0, 3)
		# if the direction is top and the top position has not been used
		if random_pos == 0 && top_used == false:
			# add a slime_to_be_spawned at the location
			slime_to_be_spawned += [spawn_location.top]
			# play the spawning slime animation
			animated_top.show()
			animated_top.play("default")
			# set top_used to true
			top_used = true
		# if the direction is right and the right position has not been used
		elif random_pos == 1 && right_used == false:
			# add a slime_to_be_spawned at the location
			slime_to_be_spawned += [spawn_location.right]
			# play the spawning slime animation
			animated_right.show()
			animated_right.play("default")
			# set right_used to true
			right_used = true
		# if the direction is left and the left position has not been used
		elif random_pos == 2 && left_used == false:
			# add a slime_to_be_spawned at the location
			slime_to_be_spawned += [spawn_location.left]
			# play the spawning slime animation
			animated_left.show()
			animated_left.play("default")
			# set left_used to true
			left_used = true
		# if the direction is bottom and the bottom position has not been used
		elif random_pos == 3 && bottom_used == false:
			# add a slime_to_be_spawned at the location
			slime_to_be_spawned += [spawn_location.bottom]
			# play the spawning slime animation
			animated_bottom.show()
			animated_bottom.play("default")
			# set bottom_used to true
			bottom_used = true
	
	# start the freeze gelatinous cube timer
	spawn_freeze_timer.start()
	# reset the attack_timer
	attack_timer.start()
	# disable attack and movement
	can_attack = false
	can_move = false
	# play the spawn slime animation
	animated_sprite.play("spawn_slime")

# when the attack timer runs out
func _on_attack_timer_timeout():
	# the slime can attack
	can_attack = true

# when the death timer runs out
func _on_death_timer_timeout():
	# hide the health bar
	hud.hide_health_bar()
	# unlock the enemy in the catalog
	catalog.unlock_enemy(EnemyTypes.enemy.gelatinous_cube)
	# call enemy_slain()
	enemy_slain()

# when spawning in
func spawn_in():
	# set the gel_cube state to spawning
	spawning = true
	# play spawning animation
	animated_sprite.play("spawning")
	# start the spawn timer
	spawn_timer.start()
	# start the spawn sound timer
	# NOTE: this is the offset between the spawning animation and the spawning sound
	spawn_sound_timer.start()

# when the spawn timer ends
func _on_spawn_timer_timeout():
	# the state is no longer spawning
	spawning = false
	# stops the spawn timer (just to make sure it doesn't loop)
	spawn_timer.stop()
	# show the gelatinous cube's health bar in the HUD
	hud.set_health_bar(max_health, "Gelatinous Cube")

# when the spawn freeze timer ends
# NOTE: this is for spawning in slime
func _on_spawn_freeze_timer_timeout():
	# for each slime to be spawned
	for spawn in slime_to_be_spawned:
		# creat a green slime
		var green_slime = GREEN_SLIME.instantiate()
		# make the green slime a child of the scene and not the gel cube
		get_parent().add_child(green_slime)
		# tell the green slime they spawned in the room
		green_slime.spawned_in_room()
		# set the position of the green slime
		if spawn == spawn_location.top:
			green_slime.global_position = spawner_top.global_position
		elif spawn == spawn_location.right:
			green_slime.global_position = spawner_right.global_position
		elif spawn == spawn_location.left:
			green_slime.global_position = spawner_left.global_position
		elif spawn == spawn_location.bottom:
			green_slime.global_position = spawner_bottom.global_position
		# check for a collision at the spawn location
		var vect = Vector2(0.0,0.0)
		var collision = green_slime.move_and_collide(vect)
		# if there is a collision at the location, despawn the slime
		if collision != null:
			green_slime.despawn()
	
	# hide all the spawning sprites
	animated_bottom.hide()
	animated_left.hide()
	animated_right.hide()
	animated_top.hide()
	
	# reset the slime_to_be_spawned
	slime_to_be_spawned = []
	# stop the spawn_freeze_timer
	spawn_freeze_timer.stop()
	# start the wait after spawn timer
	wait_after_spawn_timer.start()

# when the wait after spawn timer ends, the gel_cube can move again
func _on_wait_after_spawn_timer_timeout():
	can_move = true
	wait_after_spawn_timer.stop()

# when the spawn_sound_timer ends
func _on_spawn_sound_timer_timeout():
	# play the spawn sound
	spawn_sound.play()
