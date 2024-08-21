extends StaticBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var open_timer = $open_timer

# sets the locked status
@export var locked = false

func _ready():
	if locked:
		lock()
	else:
		animated_sprite.play("gone")

# return the locked status
func is_locked():
	return locked

# unlock the door
func unlock():
	locked = false
	open_door()

# lock the door
func lock():
	locked = true
	close_door()

func open_door():
	if !locked:
		animated_sprite.play("open")
		open_timer.start()
		collision_shape.set_deferred("disabled", true)

func _on_open_timer_timeout():
	#if collision_shape != null:
	pass

func close_door():
	animated_sprite.play("close")
	# if the door is locked, skip to the end of the close animation (makes it look like the door was already closed)
	if locked:
		animated_sprite.frame = 4
	collision_shape.set_deferred("disabled", false)

func disable_door():
	if !locked:
		animated_sprite.play("gone")
		if collision_shape != null:
			collision_shape.set_deferred("disabled", true)
