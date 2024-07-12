extends Area2D

# object references
@onready var animated_sprite = $AnimatedSprite2D
@onready var immunity_timer = $immunity_timer
var immunity = false
const VOID_ORB_FRIENDLY = preload("res://Scenes/pets/void_orb_friendly.tscn")
@onready var lifetime_timer = $lifetime_timer

# variables
var move_direction
var speed = 125
var player
var is_spawned = false
var can_split = true
var spawn_friendly = false

# runs on every frame
func _process(delta):
	# check if the shadow ball is_spawned
	if is_spawned && Engine.time_scale != 0.0:
		# moves the shadow ball based on the thrown direction
		position += move_direction * speed * delta

func _physics_process(delta):
	# check if the shadow ball is_spawned
	if is_spawned && Engine.time_scale != 0.0:
		rotation += 0.15

# this is called when a Lich spawns a shadow ball
func spawned(direction, split = false):
	# set the player reference
	player = Events.player
	# set is_spawned to true
	is_spawned = true
	move_direction = direction
	can_split = split
	immunity = true
	immunity_timer.start()
	lifetime_timer.start()

# when the shadow ball hits something
func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(1, 0, true)
	elif !immunity:
		# if the body is not enemy or is a collisiong_with_player scene of an enemy
		if body != Enemy && body.name != "collision_with_player":
			if can_split:
				split()
			# remove the shadow bolt
			queue_free()

func split():
	# spawn middle
	var new_direction = Vector2(0-move_direction.x, 0-move_direction.y)
	var projectile_direction = new_direction.normalized()
	# create and spawn the void_orb to move toward the player's direction
	var void_orb = VOID_ORB_FRIENDLY.instantiate()
	get_parent().add_child(void_orb)
	void_orb.global_position = global_position
	void_orb.spawned(projectile_direction, false)
	# spawn bottom
	var radians = new_direction.angle()
	var rad_added_bottom = Vector2(cos(radians +  1.00), sin(radians +  1.00))
	rad_added_bottom = rad_added_bottom.normalized()
	var void_orb_2 = VOID_ORB_FRIENDLY.instantiate()
	get_parent().add_child(void_orb_2)
	void_orb_2.global_position = global_position
	void_orb_2.spawned(rad_added_bottom, false)
	# spawn top
	var rad_added_top = Vector2(cos(radians -  1.00), sin(radians - 1.00))
	rad_added_top = rad_added_top.normalized()
	var void_orb_3 = VOID_ORB_FRIENDLY.instantiate()
	get_parent().add_child(void_orb_3)
	void_orb_3.global_position = global_position
	void_orb_3.spawned(rad_added_top, false)

func _on_immunity_timer_timeout():
	immunity = false


func _on_lifetime_timer_timeout():
	queue_free()
