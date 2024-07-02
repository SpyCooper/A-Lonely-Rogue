extends Pet

# object variables
@onready var fire_ball_sound = $fire_ball_sound

func _ready():
	# sets the pet variables
	max_health = 1
	health = max_health
	distance_from_player = 25
	speed = .05
	position += Vector2(0, distance_from_player)
	# plays the pet sound
	fire_ball_sound.play()

# ignore damage
func take_damage(_damage):
	pass

# melee damage for a pet
func _on_body_entered(body):
	# if the pet contacts an enemy
	if body is Enemy:
		# damage that enemy
		body.take_damage(1, 0, true)
		# play the pet sound
		fire_ball_sound.play()
