extends Node2D

# references
@onready var timer = $Timer
const DUSTED = preload("res://Scripts/shaders/dusted.gdshader")

# on start
func _ready():
	## requires the animated sprite to have a shader attached to it, not the character body 2d
	get_parent().get_animated_sprite().material.shader = DUSTED
	get_parent().set_dusted_status(true)
	timer.start(4)

# while the object is active
func _process(_delta):
	# if no shader is on the object, add this one
	if get_parent().get_animated_sprite().material.shader == null:
		get_parent().get_animated_sprite().material.shader = DUSTED

# when the timer ends
func _on_timer_timeout():
	# remove the dusted status
	get_parent().set_dusted_status(false)
	# remove the shader
	if get_parent().is_dusted() == false:
		get_parent().get_animated_sprite().material.shader = null
	# delete the status effect
	queue_free()
