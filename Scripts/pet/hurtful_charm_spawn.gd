extends Pet

func _ready():
	max_health = 1
	health = max_health
	distance_from_player = 20
	speed = .05
	# if it isn't supposed to take damage, just remove collision from the pet
	can_take_damage = false
	position += Vector2(0, distance_from_player)

func take_damage(damage):
	pass

# melee damage for a pet
func _on_body_entered(body):
	if body is Enemy:
		body.take_damage(1, 0, true)
