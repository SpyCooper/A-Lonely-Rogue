extends Knife

# variables

# this is called when the player is clicks
func spawned_tiny_knife(click_position):
	# $AnimatedSprite2D has to be called here since 
	# it is loaded before the object exists in the scene
	var animated_sprite = $AnimatedSprite2D
	# sets the proper rotation and orientation of the knife 
	# based on thrown direction
	move_direction = click_position
	look_at(position + move_direction)

# runs on every frane
func _process(delta):
	# moves the knife based on the thrown direction
	position += move_direction * speed * delta

# runs when a object enters the Area2D's collider
func _on_body_entered(body):
	# if the object has the method take_damage(), it will run it
	if body is Enemy && !body.is_spawning() && !body.is_dying():
		# the knife deals damage to the enemies hit
		body.take_damage(1, 0, true)
	# removes the knife from the screen
	queue_free()
