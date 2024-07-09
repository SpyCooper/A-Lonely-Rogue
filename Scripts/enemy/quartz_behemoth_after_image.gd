extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer

# when spawned
func spawned(direction):
	if direction == "right":
		animated_sprite.play("move_right")
	elif direction == "left":
		animated_sprite.play("move_left")
	# start the timer
	timer.start()

# when the timer ends
func _on_timer_timeout():
	# remove the after image
	queue_free()
