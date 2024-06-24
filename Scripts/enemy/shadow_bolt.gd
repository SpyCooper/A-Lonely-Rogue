extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D

# variables
var move_direction
var speed = 75
var player
var mage
var is_spawned = false
var call_mage = false

# runs on every frame
func _process(delta):
	# check if the shadow bolt is_spawned
	if is_spawned:
		# look at and follow the player
		var player_position = player.position
		move_direction = (player_position - global_position).normalized()
		look_at(player_position)
		# moves the shadow bolt based on the thrown direction
		position += move_direction * speed * delta

# this is called when a skeleton mage spawns a shadow bolt
func spawned(spawned_from, call_spawner_when_gone):
	# set the player reference
	player = Events.player
	# if the mage needs to know when the shadow bolt dies
	if call_spawner_when_gone == true:
		# set the mage that spawned the shadow bolt
		mage = spawned_from
		call_mage = true
	# set is_spawned to true
	is_spawned = true

# when the shadow bolt hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player
		body.player_take_damage(false, 0)
	# if the body is not enemy or is a collisiong_with_player scene of an enemy
	if body != Enemy && body.name != "collision_with_player":
		# if the mage needs to know when the shadow bolt dies
		if call_mage:
			# tell the mage that spawned the shadow bolt that the shadow bolt is destroyed
			mage.shadow_bolt_gone()
		# remove the shadow bolt
		queue_free()

# when an area enters the Destructable hitbox
func _on_destructable_hitbox_area_entered(area):
	# check if area is knife
	if area is Knife:
		# if the mage needs to know when the shadow bolt dies
		if call_mage:
			# tell the mage that spawned the shadow bolt that the shadow bolt is destroyed
			mage.shadow_bolt_gone()
		# destroy shadow_bolt
		queue_free()
