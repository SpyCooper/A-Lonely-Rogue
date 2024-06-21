extends Node2D

# references
@onready var timer = $Timer
const DUSTED = preload("res://Scripts/shaders/dusted.gdshader")
var parent

# on start
func _ready():
	# sets the parent of the dusted effect
	parent = get_parent()
	parent.set_dusted_status(true)
	# starts the timer for the effect
	timer.start(4)

# while the object is active
func _process(_delta):
	# if no shader is on the object, add this one
	if parent.get_animated_sprite().material.shader == null:
		parent.get_animated_sprite().material.shader = DUSTED

# when the timer ends
func _on_timer_timeout():
	# if the parent is an enemy or player
	if parent is Enemy || parent is Player:
		# remove the dusted status
		parent.set_dusted_status(false)
		# remove the shader
		if parent.is_dusted() == false:
			parent.get_animated_sprite().material.shader = null
	# delete the status effect
	queue_free()
