extends Area2D

# variables
var move_direction
var speed = 150
var animated_sprite
var dust_player = false
const DUST_BLADE_EFFECT = preload("res://Scenes/status_effects/dust_blade_effect.tscn")

# this is called when the player is clicks
func spawned(click_position, dust_blade_active):
	# sets the proper rotation and orientation of the knife 
	# based on thrown direction
	move_direction = click_position
	look_at(position + move_direction)
	animated_sprite = $AnimatedSprite2D
	
	dust_player = dust_blade_active
	print(dust_blade_active)
	if dust_blade_active:
		animated_sprite.play("dust_blade")

# runs on every frane
func _process(delta):
	# moves the knife based on the thrown direction
	position += move_direction * speed * delta

# runs when a object enters the Area2D's collider
func _on_body_entered(body):
	# if the object has the method take_damage(), it will run it
	if body is Player:
		# the knife deals damage to the enemies hit
		body.player_take_damage()
		if dust_player:
			body.add_child(DUST_BLADE_EFFECT.instantiate())
	
	# removes the knife from the screen
	queue_free()
