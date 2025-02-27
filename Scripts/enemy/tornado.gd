extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D

# variables
var move_direction
var speed = 150

# this is called when a earth_elemental throws a tornado
func spawned(target_direction, direction):
	# sets the tornado motion in the correct direction
	if direction == Enemy.look_direction.right:
		animated_sprite.play("move_right")
	elif direction == Enemy.look_direction.left:
		animated_sprite.play("move_left")
	# sets the move direction to the target direction
	move_direction = target_direction

# runs on every frane
func _process(delta):
	if  Engine.time_scale != 0.0:
		# moves the tornado based on the thrown direction
		position += move_direction * speed * delta

# when the tornado hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
		body.player_take_damage(false, 0)
	# if the body is not enemy or is a collisiong_with_player scene of an enemy
	if body != Enemy && body.name != "collision_with_player":
		# remove the tornado
		queue_free()

# when the tornado hits something
func _on_area_entered(area):
	# if the body is a pet, deal damage to it
	if area is Pet:
		area.take_damage(1)
		# remove the tornado
		queue_free()
