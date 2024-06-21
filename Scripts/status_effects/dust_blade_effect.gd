extends Node2D

# references
@onready var timer = $Timer
const DUSTED = preload("res://Scripts/shaders/dusted.gdshader")
var parent
var slow = 0.35

# on start
func _ready():
	parent = get_parent()
	if parent is Player:
		print("dust_on_player")
		parent.apply_slow(slow, true)
		if parent.dusted == false:
			parent.dusted = true
		
	elif parent is Enemy:
		## requires the animated sprite to have a shader attached to it, not the character body 2d
		parent.set_dusted_status(true)
		parent.get_animated_sprite().material.shader = DUSTED
	timer.start(4)

# while the object is active
func _process(_delta):
	# if no shader is on the object, add this one
	if parent.get_animated_sprite().material.shader == null:
		parent.get_animated_sprite().material.shader = DUSTED

# when the timer ends
func _on_timer_timeout():
	if parent is Player:
		parent.remove_slow(slow)
		parent.dusted = false
		parent.get_animated_sprite().material.shader = null
	elif parent is Enemy:
		# remove the dusted status
		parent.set_dusted_status(false)
		# remove the shader
		if parent.is_dusted() == false:
			parent.get_animated_sprite().material.shader = null
	# delete the status effect
	queue_free()
