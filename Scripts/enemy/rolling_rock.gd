extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D

# variables
var move_direction
var speed = 140

# this is called when a earth_elemental throws a rock
func spawned(target_direction, direction):
	# sets the rock motion in the correct direction
	animated_sprite.look_at(target_direction)
	# sets the move direction to the target firstion
	move_direction = target_direction

# runs on every frane
func _process(delta):
	# moves the rock based on the thrown direction
	position += move_direction * speed * delta

# when the rock hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player
		body.player_take_damage()
	# if the body is not enemy or is a collisiong_with_player scene of an enemy
	if body != Enemy && body.name != "collision_with_player":
		# remove the rock
		queue_free()
