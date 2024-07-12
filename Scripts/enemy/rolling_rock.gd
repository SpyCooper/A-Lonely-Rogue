extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D
const ROCK_BREAK = preload("res://Scenes/enemies/rolling_rock/rock_break.tscn")

# variables
var move_direction
var speed = 130

# this is called when a earth_elemental throws a rock
func spawned(target_direction, direction):
	# sets the move direction to the target direction
	move_direction = target_direction
	# sets the rock motion in the correct direction
	look_at(move_direction + global_position)

# runs on every frane
func _process(delta):
	if Engine.time_scale != 0.0:
		# moves the rock based on the thrown direction
		position += move_direction * speed * delta

# when the rock hits something
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
		# instatiate the rock break scene
		var rock_break = ROCK_BREAK.instantiate()
		rock_break.global_position = global_position
		get_parent().add_child(rock_break)
		# remove the rock
		queue_free()

# when the rock hits something
func _on_area_entered(area):
	# if the body is a pet, deal damage to it
	if area is Pet:
		area.take_damage(1)
		# instatiate the rock break scene
		var rock_break = ROCK_BREAK.instantiate()
		rock_break.global_position = global_position
		get_parent().add_child(rock_break)
		# remove the rock
		queue_free()

