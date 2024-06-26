extends Knife

@onready var life_time_timer = $life_time_timer
var spawned_tiny_knife_bool = false
var life_time_timer_started = false

# this is called when the player is clicks
func spawned_tiny_knife(click_position):
	# sets the proper rotation and orientation of the knife 
	# based on thrown direction
	move_direction = click_position
	look_at(position + move_direction)
	# starts the life time timer
	spawned_tiny_knife_bool = true

# runs on every frane
func _process(delta):
	if spawned_tiny_knife_bool:
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
		# removes the knife from the screen
		queue_free()

# when the life time timer ends
func _on_life_time_timer_timeout():
	# remove the knife
	queue_free()
