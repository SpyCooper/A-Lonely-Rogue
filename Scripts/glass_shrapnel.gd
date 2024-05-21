extends GPUParticles2D

@onready var timer = $Timer
@onready var hitbox = $hitbox


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if emitting == false:
		queue_free()


func _on_area_2d_body_entered(body):
	if body is Enemy:
		body.take_damage(1)


func _on_timer_timeout():
	hitbox.queue_free()
