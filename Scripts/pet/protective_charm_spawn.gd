extends Pet

# object variables
@onready var star_sound = $star_sound

# on start
func _ready():
	# set pet variables
	max_health = 5
	health = max_health
	distance_from_player = 15
	position += Vector2(0, distance_from_player)
	# play the pet sound
	star_sound.play()

# when the pet takes damage
func take_damage(damage):
	# remove health
	health -= damage
	# play the pet sound
	star_sound.play()
	# if health is 0
	if health <= 0:
		# tell the player the pet died
		get_parent().pet_died(ItemType.type.protective_charm)
		# remove the pet
		kill_pet()
