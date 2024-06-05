extends Enemy

# general enemy variables
var target_position
var current_direction : look_direction

# sets the enemy's stats and references
func _ready():
	speed = .75
	health = 10
	sleep()
	player = Events.player
	max_health = health
	catalog = Events.catalog

func wake_up():
	# player is now in the room
	player_in_room = true
	spawning = false
	# the spawn animation is played
	#animated_sprite.play("spawning")
	# the spawn_timer is started
	#spawn_timer.start()
	# the spawn sound in played
	#spawn_sound.play()


# called every frame
func _physics_process(_delta):
	# if the player is in the room, the slime isn't dying, and isn't spawning
	if player_in_room && !dying && !spawning:
		# checks for a reference to the player and that the game isn't paused
		if player && Engine.time_scale != 0.0:
			# gets the target player position
			player_position = player.position
			target_position = (player_position - global_position).normalized()
			current_direction = get_left_right_look_direction(target_position)
			
			# flips the direction of the slime based on the if the target is on the left or right
			#if current_direction == look_direction.left:
				## if any of the hit animations are playing
				#if animated_sprite.animation == "hit_right" :
					## switch to the same frame of the hit animation in the new direction
					## this keeps hit animations running for the same duration
					#var frame = animated_sprite.frame
					#animated_sprite.play("hit_left")
					#animated_sprite.frame = frame
				## if a hit animation is not actively playing a hit animation
				#elif playing_hit_animation != true || animated_sprite.is_playing() == false:
					## plays the basic move animation and sets the playing_hit_animation to false
					#animated_sprite.play("look_left")
					#playing_hit_animation = false
			#elif current_direction == look_direction.right:
				#if animated_sprite.animation == "hit_left" :
					#var frame = animated_sprite.frame
					#animated_sprite.play("hit_right")
					#animated_sprite.frame = frame
				#elif playing_hit_animation != true || animated_sprite.is_playing() == false:
					#animated_sprite.play("look_right")
					#playing_hit_animation = false
			
			# moves the slime to the player with a distance of 10
			if position.distance_to(player_position) > 10:
				## has to use get_speed() to move based on dusted effect
				move_and_collide(target_position.normalized() * get_speed())

# runs when a knife (or other weapon) hits the enemy
func take_damage(damage):
	# checks if the slime is not spawning or dying
	if spawning == false && dying == false:
		# subtracts the health
		health -= damage
		# if health is greater than 0
		#if health > 0:
			## play the hit animation based on the look direction
			#if current_direction == look_direction.left:
				#animated_sprite.play("hit_left")
			#elif current_direction == look_direction.right:
				#animated_sprite.play("hit_right")
			## set the playing_hit_animation to true
			#playing_hit_animation = true
			## play the hit sound
			#hit_sound.play()
		## if the health is 0 or less
		if health <= 0:
			## set the state to dying
			#dying = true
			## play the dying animation
			#animated_sprite.play("dying")
			## set movement velocity to 0 (stops movement)
			#velocity = Vector2(0.0,0.0)
			## plays the sound sound and starts the death timer
			#death_timer.start()
			#death_sound.play()
			queue_free()
