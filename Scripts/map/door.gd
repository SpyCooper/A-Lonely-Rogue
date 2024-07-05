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

func _on_open_timer_timeout():
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

func close_door():
	animated_sprite.play("close")
	collision_shape.set_deferred("disabled", false)
	
func disable_door():
	if !locked:
		animated_sprite.play("gone")
		if collision_shape != null:
			collision_shape.set_deferred("disabled", true)
