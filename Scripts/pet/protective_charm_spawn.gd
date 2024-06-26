extends Pet

# object variables
@onready var star_sound = $star_sound
@onready var animated_sprite = $AnimatedSprite2D
@onready var hit_flash_animation_player = $Hit_Flash_animation_player
@onready var hit_flash_animation_timer = $Hit_Flash_animation_player/hit_flash_animation_timer
const HIT_SHADER = preload("res://Scripts/shaders/enemy_hit_shader.gdshader")

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
	# if health is above 0
	if health > 0:
		# plays the hit animation
		animated_sprite.material.shader = null
		animated_sprite.material.shader = HIT_SHADER
		hit_flash_animation_player.play("hit_flash")
		hit_flash_animation_timer.start()
		# play the pet sound
		star_sound.play()
	# if health is 0
	elif health <= 0:
		# tell the player the pet died
		get_parent().pet_died(ItemType.type.protective_charm)
		# remove the pet
		kill_pet()

# when the hit flash animation timer ends
func _on_hit_flash_animation_timer_timeout():
	# remove the hit flash shader
	animated_sprite.material.shader = null
