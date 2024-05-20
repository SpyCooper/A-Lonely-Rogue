extends Node2D

@onready var timer = $Timer
const POISONED = preload("res://Scripts/shaders/poisoned.gdshader")

func _ready():
	get_parent().find_child("AnimatedSprite2D").material.shader = POISONED
	get_parent().toggle_poisoned()
	timer.start(1.5)


func _on_timer_timeout():
	get_parent().take_damage(1)
	get_parent().find_child("AnimatedSprite2D").material.shader = null
	get_parent().toggle_poisoned()
	queue_free()
