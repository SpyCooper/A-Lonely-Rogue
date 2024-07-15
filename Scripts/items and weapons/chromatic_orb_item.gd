extends Node2D

@onready var animated_sprite = $AnimatedSprite2D

func spawned():
	animated_sprite.play("smoke")
	global_position = global_position + Vector2(0, 8)

func _process(_delta):
	if Engine.time_scale != 0:
		if !animated_sprite.is_playing():
			animated_sprite.play("default")

