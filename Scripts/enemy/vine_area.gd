extends Node2D

# object references
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var life_timer = $life_timer
@onready var area_2d = $Area2D
@onready var exit_timer = $exit_timer
@onready var enter_timer = $enter_timer
@onready var enter_sound = $enter_sound
@onready var exit_sound = $"exit sound"

# variables
var slow = 0.35
var spawned_by

# on ready
func _ready():
	# play the enter animation and start enter timer
	animated_sprite_2d.play("enter")
	enter_timer.start()
	# plays the enter sound
	enter_sound.play()

# when a body enters the hitbox
func _on_area_2d_body_entered(body):
	# if the body is the player, slow them
	if body is Player:
		body.apply_slow(slow, false)

# when a body leaves the hitbox (this is called before queue_free() is ran)
func _on_area_2d_body_exited(body):
	# if the body is the player, remove the slow 
	if body is Player:
		body.remove_slow(slow)

# when spawned
func spawned(spawner, pos):
	# set position (has to do with sorting and the ground)
	position = pos - area_2d.position
	# set who spawned the vines (should just be the forgotten golem)
	spawned_by = spawner

# when the enter timer ends
func _on_enter_timer_timeout():
	# start the life timer
	life_timer.start()

# when the life timer ends
func _on_life_timer_timeout():
	# play the exit animation and start exit timer
	animated_sprite_2d.play("exit")
	exit_timer.start()
	# plays the exit sound
	exit_sound.play()

# when the exit timer ends
func _on_exit_timer_timeout():
	# check if the spawner is not null
	if spawned_by != null:
		# tell them the vines are gone
		spawned_by.vines_expired()
	# remove the vines
	queue_free()

