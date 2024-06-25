extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D

# variables
var move_direction
var speed = 100

# this is called when a skeleton_warrior spawns a slash projectile
func spawned(target_direction):
	# sets the move direction to the target direction
	move_direction = target_direction
	look_at(position + move_direction)

# runs on every frane
func _process(delta):
	# moves the slash based on the thrown direction
	position += move_direction * speed * delta

# when the slash hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
		body.player_take_damage(false, 0)
	# if the body is a pet, deal damage to it
	if body is Pet:
		body.take_damage(1)
	# if the body is not enemy or is a collisiong_with_player scene of an enemy
	if body != Enemy && body.name != "collision_with_player":
		# remove the slash
		queue_free()
