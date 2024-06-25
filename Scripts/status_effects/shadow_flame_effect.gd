extends Node2D

# references
@onready var timer = $Timer
const SHADOW_FLAME = preload("res://Scripts/shaders/shadow_flame.gdshader")

# on start
func _ready():
	## requires the animated sprite to have a shader attached to it, not the character body 2d
	get_parent().get_animated_sprite().material.shader = SHADOW_FLAME
	get_parent().toggle_shadow_flamed()
	timer.start(5)

# while the object is active
func _process(_delta):
	# if no shader is on the object, add this one
	if get_parent().get_animated_sprite().material.shader == null:
		get_parent().get_animated_sprite().material.shader = SHADOW_FLAME

# when the timer ends
func _on_timer_timeout():
	# damage the enemy ( 2 damage, attack identifier, is a status effect)
	get_parent().take_damage(2, 0, true)
	# toggle shadow_flame status
	get_parent().toggle_shadow_flamed()
	# remove the shader
	get_parent().find_child("AnimatedSprite2D").material.shader = null
	# delete the status effect
	queue_free()
