extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D
const VOID_ORB = preload("res://Scenes/enemies/void_orb/void_orb.tscn")
@onready var immunity_timer = $immunity_timer
var immunity = false
const VOID_ORB_SPLIT_SOUND = preload("res://Scenes/enemies/void_orb/void_orb_split_sound.tscn")

# variables
var move_direction
var speed = 125
var player
var is_spawned = false
var can_split = true

# runs on every frame
func _process(delta):
	# check if the void orb is_spawned
	if is_spawned:
		# moves the void orb based on the thrown direction
		position += move_direction * speed * delta

func _physics_process(delta):
	# check if the void orb is_spawned
	if is_spawned:
		# rotates the orb
		rotation += 0.15

# this is called when the onyx demon spawns a void orb
func spawned(direction, split = false, large = false):
	# set the player reference
	player = Events.player
	# set is_spawned to true
	is_spawned = true
	# set the move direction
	move_direction = direction
	# sets if the orb can split
	can_split = split
	# sets the immunity timer (needed to not immediately get destroyed by walls
	immunity = true
	immunity_timer.start()
	# if the orb should be large, set it to be twice the size of the original
	if large:
		scale = Vector2(2, 2)

# when the void orb hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
		body.player_take_damage(false, 0)
	# if there is no immunity
	elif !immunity:
		# if the body is not enemy or is a collision_with_player scene of an enemy
		if body != Enemy && body.name != "collision_with_player":
		# split the orb is it should be able to
			if can_split:
				split()
			# remove the void orb
			queue_free()

# when the void orb hits something
func _on_area_entered(area):
	# if the body is a pet, deal damage to it
	if area is Pet:
		area.take_damage(1)
	# if there is no immunity
	elif !immunity:
		# split the orb is it should be able to
		if can_split:
			split()
		# remove the void orb
		queue_free()

# splits the void orb
func split():
	# spawn middle
	# get the direction the orb should move
	var new_direction = Vector2(0-move_direction.x, 0-move_direction.y)
	var projectile_direction = new_direction.normalized()
	# create and spawn the void_orb to move in that direction
	var void_orb = VOID_ORB.instantiate()
	get_parent().add_child(void_orb)
	void_orb.global_position = global_position
	void_orb.spawned(projectile_direction, false)
	# spawn bottom
	# get the direction the orb should move
	var radians = new_direction.angle()
	var rad_added_bottom = Vector2(cos(radians +  1.00), sin(radians +  1.00))
	rad_added_bottom = rad_added_bottom.normalized()
	# create and spawn the void_orb to move in that direction
	var void_orb_2 = VOID_ORB.instantiate()
	get_parent().add_child(void_orb_2)
	void_orb_2.global_position = global_position
	void_orb_2.spawned(rad_added_bottom, false)
	# spawn top
	# get the direction the orb should move
	var rad_added_top = Vector2(cos(radians -  1.00), sin(radians - 1.00))
	rad_added_top = rad_added_top.normalized()
	# create and spawn the void_orb to move in that direction
	var void_orb_3 = VOID_ORB.instantiate()
	get_parent().add_child(void_orb_3)
	void_orb_3.global_position = global_position
	void_orb_3.spawned(rad_added_top, false)
	# plays the destruction sound
	var split_sound = VOID_ORB_SPLIT_SOUND.instantiate()
	get_parent().add_child(split_sound)
	split_sound.global_position = animated_sprite.global_position
	split_sound.spawned()

# when the immunity timer ends, disable immunity
func _on_immunity_timer_timeout():
	immunity = false
