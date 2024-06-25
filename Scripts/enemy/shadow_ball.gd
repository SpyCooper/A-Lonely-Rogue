extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D

# variables
var move_direction
var speed = 80
var player
var is_spawned = false

# runs on every frame
func _process(delta):
	# check if the shadow ball is_spawned
	if is_spawned:
		# look at and follow the player
		var player_position = player.position
		move_direction = (player_position - global_position).normalized()
		look_at(player_position)
		# moves the shadow ball based on the thrown direction
		position += move_direction * speed * delta

# this is called when a Lich spawns a shadow ball
func spawned():
	# set the player reference
	player = Events.player
	# set is_spawned to true
	is_spawned = true

# when the shadow ball hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
		body.player_take_damage(false, 0)
	# if the body is not enemy or is a collisiong_with_player scene of an enemy
	if body != Enemy && body.name != "collision_with_player":
		# remove the shadow bolt
		queue_free()

# when an area enters the Destructable hitbox
func _on_destructable_hitbox_area_entered(area):
	# check if area is knife
	if area is Knife:
		# destroy shadow_ball
		queue_free()
