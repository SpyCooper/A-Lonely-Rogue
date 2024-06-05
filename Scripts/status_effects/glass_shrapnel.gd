extends GPUParticles2D

# object references
@onready var hitbox = $hitbox

# on start
func _process(_delta):
	# if emitting is false, delete the object
	if emitting == false:
		queue_free()

# if an enemy enters the glass sharpnel area, deal 1 damage
func _on_area_2d_body_entered(body):
	if body is Enemy:
		body.take_damage(1)

# when the auto timer ends, delete the  hitbox
func _on_timer_timeout():
	hitbox.queue_free()
