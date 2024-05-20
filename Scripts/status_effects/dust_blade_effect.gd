extends Node2D

@onready var timer = $Timer
const DUSTED = preload("res://Scripts/shaders/dusted.gdshader")

func _ready():
	get_parent().find_child("AnimatedSprite2D").material.shader = DUSTED
	get_parent().set_dusted_status(true)
	timer.start(4)

func _on_timer_timeout():
	get_parent().set_dusted_status(false)
	if get_parent().is_dusted() == false:
		get_parent().find_child("AnimatedSprite2D").material.shader = null
	queue_free()
