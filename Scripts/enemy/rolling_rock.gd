extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D

# variables
var move_direction
var speed = 145

# this is called when a earth_elemental throws a rock
func spawned(target_direction, direction):
	# sets the rock motion in the correct direction
	if direction == Enemy.look_direction.up:
		animated_sprite.play("up")
	elif direction == Enemy.look_direction.down:
		animated_sprite.play("down")
	elif direction == Enemy.look_direction.left:
		animated_sprite.play("left")
	elif direction == Enemy.look_direction.right:
		animated_sprite.play("right")
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
