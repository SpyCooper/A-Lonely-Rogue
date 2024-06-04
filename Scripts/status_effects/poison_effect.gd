extends Node2D

# references
@onready var timer = $Timer
const POISONED = preload("res://Scripts/shaders/poisoned.gdshader")

# on start
func _ready():
	## requires the animated sprite to have a shader attached to it, not the character body 2d
	get_parent().get_animated_sprite().material.shader = POISONED
	get_parent().toggle_poisoned()
	timer.start(1.5)

# while the object is active
func _process(_delta):
	# if no shader is on the object, add this one
	if get_parent().get_animated_sprite().material.shader == null:
		get_parent().get_animated_sprite().material.shader = POISONED

# when the timer ends
func _on_timer_timeout():
	# deal 1 damage to the enemy
	get_parent().take_damage(1)
	# toggle poison status
	get_parent().toggle_poisoned()
	# remove the shader
	get_parent().find_child("AnimatedSprite2D").material.shader = null
	# delete the status effect
	queue_free()
