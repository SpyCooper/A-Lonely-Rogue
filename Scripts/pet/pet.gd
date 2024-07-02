extends Area2D

class_name Pet

# pet variables
var angle = 0.0
var distance_from_player = 15
var max_health
var health
var speed = 0.10

# on start
func _ready():
	# set pet variables
	max_health = 5
	health = max_health
	distance_from_player = 15
	speed = 0.10
	position += Vector2(0, distance_from_player)

# called on set intervals
func _physics_process(_delta):
	# circles around the player
	angle += speed
	global_position = Events.player.global_position + Vector2.RIGHT.rotated(angle) * distance_from_player
	look_at(Events.player.position)

# basic damage function
func take_damage(damage):
	health -= damage
	if health <= 0:
		get_parent().pet_died(ItemType.type.temp)
		kill_pet()

# resets the pet's hp
func reset_hp():
	health = max_health

# sets the pet's hp
func set_pet_hp(hp):
	health = hp

# melee damage for a pet
func _on_body_entered(_body):
	pass

func kill_pet():
	queue_free()
