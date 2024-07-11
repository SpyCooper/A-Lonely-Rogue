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
	# check if the shadow ball is_spawned
	if is_spawned:
		# moves the shadow ball based on the thrown direction
		position += move_direction * speed * delta

func _physics_process(delta):
	# check if the shadow ball is_spawned
	if is_spawned:
		rotation += 0.15

# this is called when a Lich spawns a shadow ball
func spawned(direction, split = false, large = false):
	# set the player reference
	player = Events.player
	# set is_spawned to true
	is_spawned = true
	move_direction = direction
	can_split = split
	immunity = true
	immunity_timer.start()
	if large:
		scale = Vector2(2, 2)

# when the shadow ball hits something
func _on_body_entered(body):
	# if the object is a player
	if body is Player:
		# damage player (it is not a morphed_shade attack, attack_identifer doesn't matter so 0)
		body.player_take_damage(false, 0)
	elif !immunity:
		# if the body is not enemy or is a collisiong_with_player scene of an enemy
		if body != Enemy && body.name != "collision_with_player":
			if can_split:
				split()
			# remove the shadow bolt
			queue_free()

# when the shadow ball hits something
func _on_area_entered(area):
	# if the body is a pet, deal damage to it
	if area is Pet:
		area.take_damage(1)
		if !immunity:
			if can_split:
				split()
			# remove the tornado
			queue_free()

func split():
	# spawn middle
	var new_direction = Vector2(0-move_direction.x, 0-move_direction.y)
	var projectile_direction = new_direction.normalized()
	# create and spawn the void_orb to move toward the player's direction
	var void_orb = VOID_ORB.instantiate()
	get_parent().add_child(void_orb)
	void_orb.global_position = global_position
	void_orb.spawned(projectile_direction, false)
	# spawn bottom
	var radians = new_direction.angle()
	var rad_added_bottom = Vector2(cos(radians +  1.00), sin(radians +  1.00))
	rad_added_bottom = rad_added_bottom.normalized()
	var void_orb_2 = VOID_ORB.instantiate()
	get_parent().add_child(void_orb_2)
	void_orb_2.global_position = global_position
	void_orb_2.spawned(rad_added_bottom, false)
	# spawn top
	var rad_added_top = Vector2(cos(radians -  1.00), sin(radians - 1.00))
	rad_added_top = rad_added_top.normalized()
	var void_orb_3 = VOID_ORB.instantiate()
	get_parent().add_child(void_orb_3)
	void_orb_3.global_position = global_position
	void_orb_3.spawned(rad_added_top, false)
	
	# plays the death sound
	var split_sound = VOID_ORB_SPLIT_SOUND.instantiate()
	get_parent().add_child(split_sound)
	split_sound.global_position = animated_sprite.global_position
	split_sound.spawned()


func _on_immunity_timer_timeout():
	immunity = false
