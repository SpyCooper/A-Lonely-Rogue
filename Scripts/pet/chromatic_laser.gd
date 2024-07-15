extends Area2D

@onready var life_time_timer = $life_time_timer
var life_time_timer_started = false
var spawned_laser = true
var move_direction
var speed = 175

# this is called when the player is clicks
func spawned(target_position):
	# sets the proper rotation and orientation of the knife 
	# based on thrown direction
	move_direction = target_position
	look_at(position + move_direction)
	# starts the life time timer
	life_time_timer_started = true

# runs on every frane
func _process(delta):
	if spawned_laser && Engine.time_scale != 0.0:
		# moves the knife based on the thrown direction
		position += move_direction * speed * delta
		# start the life_time_timer if it hasn't been started
		if !life_time_timer_started:
			life_time_timer.start()
			life_time_timer_started = true

# runs when a object enters the Area2D's collider
func _on_body_entered(body):
	# if the object has the method take_damage(), it will run it
	if body is Enemy && !body.is_spawning() && !body.is_dying():
		# the knife deals damage to the enemies hit
		body.take_damage(1, 0, true)
	if body != Player:
		# plays the knife hit sound
		#var knife_hit_sound = KNIFE_HIT.instantiate()
		#knife_hit_sound.position = position
		#get_parent().add_child(knife_hit_sound)
		# removes the knife from the screen
		queue_free()

# when the life time timer ends
func _on_life_time_timer_timeout():
	# remove the knife
	queue_free()
