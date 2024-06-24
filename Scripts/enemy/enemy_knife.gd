extends Area2D

# variables
var move_direction
var speed = 150
var animated_sprite
var dust_player = false
const DUST_BLADE_EFFECT = preload("res://Scenes/status_effects/dust_blade_effect.tscn")
var attack_identifer

# this is called when the player is clicks
func spawned(click_position, dust_blade_active, current_attack_identifier, knife_speed_bonus):
	# sets the proper rotation and orientation of the knife 
	# based on thrown direction
	move_direction = click_position
	look_at(position + move_direction)
	# sets the attack_identifier
	attack_identifer = current_attack_identifier
	# sets the reference to the animated sprite
	animated_sprite = $AnimatedSprite2D
	# checks to see if a dust blade was obtained
	dust_player = dust_blade_active
	if dust_blade_active:
		animated_sprite.play("dust_blade")
	speed += knife_speed_bonus

# runs on every frane
func _process(delta):
	# moves the knife based on the thrown direction
	position += move_direction * speed * delta

# runs when a object enters the Area2D's collider
func _on_body_entered(body):
	# checks if the object is the player
	if body is Player:
		# the knife deals damage to the enemies hit
		body.player_take_damage(true, attack_identifer)
		# if a dust blade was obtained
		if dust_player:
			# add the dust blade effect to the player
			body.add_child(DUST_BLADE_EFFECT.instantiate())
	# removes the knife from the screen
	queue_free()
