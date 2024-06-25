extends Pet


func _ready():
	max_health = 5
	health = max_health
	distance_from_player = 15
	position += Vector2(0, distance_from_player)

func take_damage(damage):
	health -= damage
	if health <= 0:
		get_parent().pet_died(ItemType.type.protective_charm)
		queue_free()

func reset_hp():
	health = max_health

func set_pet_hp(hp):
	health = hp

