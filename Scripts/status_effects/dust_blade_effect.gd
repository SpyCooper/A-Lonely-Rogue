extends Node2D

@onready var timer = $Timer
const DUSTED = preload("res://Scripts/shaders/dusted.gdshader")

func _ready():
	## requires the animated sprite to have a shader attached to it, not the character body 2d
	get_parent().get_animated_sprite().material.shader = DUSTED
	get_parent().set_dusted_status(true)
	timer.start(4)

func _on_timer_timeout():
	get_parent().set_dusted_status(false)
	if get_parent().is_dusted() == false:
		get_parent().get_animated_sprite().material.shader = null
	queue_free()
