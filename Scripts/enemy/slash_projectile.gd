extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D

# variables
var move_direction
var speed = 100

# this is called when a earth_elemental throws a tornado
func spawned(target_direction):
	# sets the move direction to the target direction
	move_direction = target_direction
	look_at(position + move_direction)

# runs on every frane
func _process(delta):
	# moves the tornado based on the thrown direction
	position += move_direction * speed * delta

# when the tornado hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player
		body.player_take_damage()
	# if the body is not enemy or is a collisiong_with_player scene of an enemy
	if body != Enemy && body.name != "collision_with_player":
		# remove the tornado
		queue_free()
