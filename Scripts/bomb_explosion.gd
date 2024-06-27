extends Node2D

@onready var explosion_sound = $explosion_sound
@onready var life_time_timer = $life_time_timer

func spawned():
	# start the life timer
	life_time_timer.start()

func _on_body_entered(body):
	# if the object is an enemy
	if body is Enemy && !body.is_spawning() && !body.is_dying():
		# the explosion deals damage to the enemies hit
		body.take_damage(1, 0, true)

# when the life timer ends remove the damage area
func _on_life_time_timer_timeout():
	queue_free()
