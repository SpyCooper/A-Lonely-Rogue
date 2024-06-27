extends Node2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var timer = $Timer

# when spawned
func spawned():
	# set the same animation as the player
	animated_sprite.play(Events.player.get_animated_sprite().animation)
	# start the timer
	timer.start()

# when the timer ends
func _on_timer_timeout():
	# remove the after image
	queue_free()
