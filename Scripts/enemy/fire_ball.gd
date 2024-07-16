extends Area2D

# variables
var move_direction
var speed = 180

# this is called when the forgotten golem spawns an laser
func spawned(target_direction):
	# sets the move direction to the target direction
	move_direction = target_direction
	# looks at the move direction
	look_at(position + move_direction)

# runs on every frame
func _process(delta):
	if Engine.time_scale != 0.0:
		# moves the laser based on the thrown direction
		position += move_direction * speed * delta

# when the laser hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
		body.player_take_damage(false, 0)
	# if the body is not enemy or is a collisiong_with_player scene of an enemy
	if body != Enemy && body.name != "collision_with_player":
		# remove the laser
		queue_free()

# when the laser hits something
func _on_area_entered(area):
	# if the body is a pet, deal damage to it
	if area is Pet:
		area.take_damage(1)
		queue_free()
