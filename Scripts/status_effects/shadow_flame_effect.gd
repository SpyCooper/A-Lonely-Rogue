extends Node2D

@onready var timer = $Timer
const SHADOW_FLAME = preload("res://Scripts/shaders/shadow_flame.gdshader")



func _ready():
	## requires the animated sprite to have a shader attached to it, not the character body 2d
	get_parent().get_animated_sprite().material.shader = SHADOW_FLAME
	get_parent().toggle_shadow_flamed()
	timer.start(5)


func _on_timer_timeout():
	get_parent().take_damage(2)
	get_parent().toggle_shadow_flamed()
	queue_free()
