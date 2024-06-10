extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D

# variables
var move_direction
var speed = 100
var player
var mage
var is_spawned = false

# runs on every frame
func _process(delta):
	if is_spawned:
		var player_position = player.position
		move_direction = (player_position - global_position).normalized()
		look_at(player_position)
		# moves the tornado based on the thrown direction
		position += move_direction * speed * delta

# this is called when a earth_elemental throws a tornado
func spawned(spawned_from_mage):
	# sets the move direction to the target direction
	player = Events.player
	mage = spawned_from_mage
	is_spawned = true

# when the tornado hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player
		body.player_take_damage()
	
	mage.shadow_bolt_gone()
	
	# if the body is not enemy or is a collisiong_with_player scene of an enemy
	if body != Enemy && body.name != "collision_with_player":
		# remove the tornado
		queue_free()
