extends Area2D

# constant variables
const SPEED = 150

# variables
var move_direction

# this is called when the player is clicks
func spawned(player_pos):
	# $AnimatedSprite2D has to be called here since 
	# it is loaded before the object exists in the scene
	var animated_sprite = $AnimatedSprite2D
	
	# sets the proper rotation and orientation of the knife 
	# based on thrown direction
	if position.x > player_pos.x:
		# knife is moving right
		rotation_degrees = -90
		animated_sprite.flip_h = true
		animated_sprite.flip_v = true
		move_direction = "r"
	elif position.x < player_pos.x:
		# knife is moving left
		rotation_degrees = 90
		animated_sprite.flip_v = true
		move_direction = "l"
	elif position.y < player_pos.y:
		# knife is moving up
		animated_sprite.flip_v = false
		move_direction = "u"
	else:
		# knife is moving down
		move_direction = "d"

# runs on every frane
func _process(delta):
	# moves the knife based on the thrown direction
	if move_direction == "r":
		position.x += SPEED * delta
	elif move_direction == "l":
		position.x -= SPEED * delta
	elif move_direction == "u":
		position.y -= SPEED * delta
	else:
		position.y += SPEED * delta

# runs when a object enters the Area2D's collider
func _on_body_entered(body):
	# if the object has the method hit(), it will run it
	if body.has_method("hit"):
		body.hit()
	
	# removes the knife from the screen
	queue_free()
